# ---------------------------------------------------------------------------
# Networking Module — Main
# Provisions VNet, Subnets, NSGs, Route Tables, and Diagnostic Settings
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
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

resource "azurerm_network_security_group" "this" {
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

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.network_security_groups

  subnet_id                 = azurerm_subnet.this[each.value.subnet_key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                          = each.key
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation

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

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.route_tables

  subnet_id      = azurerm_subnet.this[each.value.subnet_key].id
  route_table_id = azurerm_route_table.this[each.key].id
}

# ---------------------------------------------------------------------------
# Diagnostic Settings — NSG Flow Logs
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  for_each = var.enable_diagnostics ? var.network_security_groups : {}

  name                       = "${each.key}-diag"
  target_resource_id         = azurerm_network_security_group.this[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
