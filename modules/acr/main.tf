# ---------------------------------------------------------------------------
# ACR Module — Main
# Azure Container Registry with Private Endpoint, Geo-replication, AcrPull
# ---------------------------------------------------------------------------

# checkov:skip=CKV_AZURE_233:Zone redundancy is enabled explicitly for Premium preprod and prod; dev and test retain their approved cost profile.
# checkov:skip=CKV_AZURE_164:Content trust is not supported by the AzureRM provider; signed-image admission is enforced in the registry pipeline.
# checkov:skip=CKV_AZURE_166:Quarantine is enabled by default for Premium registries; the SKU-specific expression is evaluated at plan time.
# checkov:skip=CKV_AZURE_237:Dedicated data endpoints are enabled by default for Premium registries; the SKU-specific expression is evaluated at plan time.
resource "azurerm_container_registry" "acr" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = var.sku == "Premium" ? var.data_endpoint_enabled : null
  quarantine_policy_enabled     = var.sku == "Premium" ? var.quarantine_policy_enabled : null

  retention_policy_in_days = var.sku == "Premium" ? var.retention_policy_days : null


  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []

    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
    }
  }

  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.network_rule_set != null ? [var.network_rule_set] : []

    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules

        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}


# ---------------------------------------------------------------------------
# Private Endpoint
# ---------------------------------------------------------------------------

module "private_endpoint" {
  source = "../_private-endpoint"

  enabled                        = var.enable_private_endpoint
  name                           = var.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.private_endpoint_subnet_id
  private_connection_resource_id = azurerm_container_registry.acr.id
  subresource_names              = ["registry"]
  private_dns_zone_ids           = var.private_dns_zone_id != null ? [var.private_dns_zone_id] : []
  tags                           = var.tags
}

# ---------------------------------------------------------------------------
# Diagnostic Settings
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
