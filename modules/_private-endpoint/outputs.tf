output "id" {
  description = "Resource ID of the private endpoint, or null if not created."
  value       = var.enabled ? azurerm_private_endpoint.private_endpoint[0].id : null
}

output "private_ip_address" {
  description = "Private IP address assigned to the private endpoint's NIC, or null if not created."
  value       = var.enabled ? azurerm_private_endpoint.private_endpoint[0].private_service_connection[0].private_ip_address : null
}

output "network_interface_id" {
  description = "Resource ID of the network interface created for the private endpoint, or null if not created."
  value       = var.enabled ? azurerm_private_endpoint.private_endpoint[0].network_interface[0].id : null
}
