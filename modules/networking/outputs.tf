# ---------------------------------------------------------------------------
# Networking Module — Outputs
# ---------------------------------------------------------------------------

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network."
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their resource IDs."
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes."
  value       = { for k, v in azurerm_subnet.subnet : k => v.address_prefixes }
}

output "nsg_ids" {
  description = "Map of NSG names to their resource IDs."
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "route_table_ids" {
  description = "Map of route table names to their resource IDs."
  value       = { for k, v in azurerm_route_table.route_table : k => v.id }
}

# ---------------------------------------------------------------------------
# Hub & Spoke Outputs
# ---------------------------------------------------------------------------

output "peering_spoke_to_hub_id" {
  description = "Resource ID of the Spoke-to-Hub VNet peering. Null if Hub integration is disabled."
  value       = var.hub_vnet_id != null ? azurerm_virtual_network_peering.spoke_to_hub[0].id : null
}

output "peering_hub_to_spoke_id" {
  description = "Resource ID of the Hub-to-Spoke VNet peering. Null if Hub integration is disabled."
  value       = var.hub_vnet_id != null ? azurerm_virtual_network_peering.hub_to_spoke[0].id : null
}

output "hub_egress_route_table_id" {
  description = "Resource ID of the Hub egress route table. Null if Firewall integration is disabled."
  value       = var.hub_firewall_private_ip != null ? azurerm_route_table.hub_egress[0].id : null
}
