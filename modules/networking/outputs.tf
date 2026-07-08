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
