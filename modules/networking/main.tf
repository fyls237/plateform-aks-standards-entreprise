# ---------------------------------------------------------------------------
# Networking Module — Main
# Provisions VNet, Subnets, NSGs, Route Tables, and Diagnostic Settings
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []

    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = length(each.value.service_endpoints) > 0 ? each.value.service_endpoints : null
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Network Security Groups
# ---------------------------------------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  for_each = var.network_security_groups

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = security_rule.value.source_address_prefix
      source_address_prefixes    = security_rule.value.source_address_prefixes
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association" {
  for_each = var.network_security_groups

  subnet_id                 = azurerm_subnet.subnet[each.value.subnet_key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------

resource "azurerm_route_table" "route_table" {
  for_each = var.route_tables

  name                          = each.key
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = !each.value.disable_bgp_route_propagation

  dynamic "route" {
    for_each = each.value.routes

    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  for_each = var.route_tables

  subnet_id      = azurerm_subnet.subnet[each.value.subnet_key].id
  route_table_id = azurerm_route_table.route_table[each.key].id
}

# ---------------------------------------------------------------------------
# Diagnostic Settings — NSG Flow Logs
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  for_each = var.enable_diagnostics ? var.network_security_groups : {}

  name                       = "${each.key}-diag"
  target_resource_id         = azurerm_network_security_group.nsg[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

# ---------------------------------------------------------------------------
# Diagnostic Settings — Virtual Network
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "vnet" {
  count = var.enable_vnet_diagnostics ? 1 : 0

  name                       = "${var.vnet_name}-diag"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  enabled_metric {
    category = "AllMetrics"
  }

  lifecycle {
    precondition {
      condition     = var.log_analytics_workspace_id != null
      error_message = "log_analytics_workspace_id must be provided when enable_vnet_diagnostics is true."
    }
  }
}

# ---------------------------------------------------------------------------
# Hub & Spoke — VNet Peering
# Conditional: only created when hub_vnet_id is provided
# ---------------------------------------------------------------------------

# Provider alias for cross-subscription peering (Hub side)
# When hub_subscription_id is set, Hub-side resources use this provider.

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count = var.hub_vnet_id != null ? 1 : 0

  name                      = "peer-spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = var.hub_use_remote_gateways

  depends_on = [azurerm_subnet.subnet]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  count = var.hub_vnet_id != null ? 1 : 0

  # Cross-subscription: if hub_subscription_id is set, the caller must
  # ensure the azurerm provider has access to the Hub subscription
  # (via a provider alias or service principal with cross-sub permissions).
  provider = azurerm

  name                      = "peer-hub-to-${var.vnet_name}"
  resource_group_name       = var.hub_vnet_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = var.hub_allow_gateway_transit
  use_remote_gateways     = false

  depends_on = [azurerm_virtual_network_peering.spoke_to_hub]
}

# ---------------------------------------------------------------------------
# Hub & Spoke — Egress Route Table (UDR to Azure Firewall)
# Conditional: only created when hub_firewall_private_ip is provided
# ---------------------------------------------------------------------------

resource "azurerm_route_table" "hub_egress" {
  count = var.hub_firewall_private_ip != null ? 1 : 0

  name                          = "rt-hub-egress-${var.vnet_name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false

  # Default route: all traffic to Azure Firewall
  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_firewall_private_ip
  }

  # Additional custom routes
  dynamic "route" {
    for_each = var.hub_additional_routes

    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "hub_egress" {
  for_each = var.hub_firewall_private_ip != null ? toset(var.hub_egress_subnet_keys) : toset([])

  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.hub_egress[0].id
}
