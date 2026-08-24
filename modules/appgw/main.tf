# ---------------------------------------------------------------------------
# Application Gateway Module — Main
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "waf" {
  name                = "waf-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = var.tags
}

locals {
  frontend_port_name             = "${var.name}-feport"
  frontend_ip_configuration_name = "${var.name}-feip"
  backend_address_pool_name      = "${var.name}-beap"
  http_setting_name              = "${var.name}-be-htst"
  listener_name                  = "${var.name}-httplstn"
  request_routing_rule_name      = "${var.name}-rqrt"
}

# ---------------------------------------------------------------------------
# Application Gateway (managed by AGIC)
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway" "agic" {
  # checkov:skip=CKV_AZURE_118: "TLS certificate integration requires Key Vault, pending implementation for base module"
  # checkov:skip=CKV_AZURE_218: "HTTP listener is a placeholder; AGIC overwrites this based on Ingress resources"
  count = var.ingress_type == "agic" ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.waf.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min_capacity
    max_capacity = var.autoscale_max_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "${local.frontend_port_name}-http"
    port = 80
  }

  dynamic "frontend_port" {
    for_each = var.key_vault_secret_id != null ? [1] : []
    content {
      name = "${local.frontend_port_name}-https"
      port = 443
    }
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  # Default values required by Azure; AGIC will overwrite these based on Ingress resources
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = var.key_vault_secret_id != null ? "${local.frontend_port_name}-https" : "${local.frontend_port_name}-http"
    protocol                       = var.key_vault_secret_id != null ? "Https" : "Http"
    ssl_certificate_name           = var.key_vault_secret_id != null ? "${var.name}-cert" : null
  }

  dynamic "ssl_certificate" {
    for_each = var.key_vault_secret_id != null ? [1] : []
    content {
      name                = "${var.name}-cert"
      key_vault_secret_id = var.key_vault_secret_id
    }
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      redirect_configuration,
      ssl_certificate,
      tags
    ]
  }
}

# ---------------------------------------------------------------------------
# Application Gateway (managed by Terraform routing to NGINX ILB)
# ---------------------------------------------------------------------------

resource "azurerm_application_gateway" "nginx" {
  # checkov:skip=CKV_AZURE_118: "TLS certificate integration requires Key Vault, pending implementation for base module"
  # checkov:skip=CKV_AZURE_218: "HTTP listener is a placeholder; pending Key Vault integration for HTTPS"
  count = var.ingress_type == "nginx" ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.waf.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min_capacity
    max_capacity = var.autoscale_max_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "${local.frontend_port_name}-http"
    port = 80
  }

  dynamic "frontend_port" {
    for_each = var.key_vault_secret_id != null ? [1] : []
    content {
      name = "${local.frontend_port_name}-https"
      port = 443
    }
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  # Route traffic to the NGINX Internal Load Balancer IP
  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [var.nginx_ilb_ip]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = var.key_vault_secret_id != null ? "${local.frontend_port_name}-https" : "${local.frontend_port_name}-http"
    protocol                       = var.key_vault_secret_id != null ? "Https" : "Http"
    ssl_certificate_name           = var.key_vault_secret_id != null ? "${var.name}-cert" : null
  }

  dynamic "ssl_certificate" {
    for_each = var.key_vault_secret_id != null ? [1] : []
    content {
      name                = "${var.name}-cert"
      key_vault_secret_id = var.key_vault_secret_id
    }
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Diagnostic Settings
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "appgw" {
  name                       = "${var.name}-diag"
  target_resource_id         = var.ingress_type == "agic" ? azurerm_application_gateway.agic[0].id : azurerm_application_gateway.nginx[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
