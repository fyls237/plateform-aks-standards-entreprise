# ---------------------------------------------------------------------------
# Key Vault Module — Main
# Azure Key Vault with RBAC, Private Endpoint, Diagnostics
# ---------------------------------------------------------------------------

resource "azurerm_key_vault" "key_vault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  enabled_for_disk_encryption   = var.enabled_for_disk_encryption
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  rbac_authorization_enabled    = var.enable_rbac_authorization
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    bypass = var.network_acls.bypass
    #trivy:ignore:AVD-AZU-0013 reason:Network ACL mode is selected by environment; dev intentionally allows Azure services while regulated environments use Deny.
    default_action             = var.network_acls.default_action
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
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
  private_connection_resource_id = azurerm_key_vault.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = var.private_dns_zone_id != null ? [var.private_dns_zone_id] : []
  tags                           = var.tags
}

# ---------------------------------------------------------------------------
# Diagnostic Settings
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
