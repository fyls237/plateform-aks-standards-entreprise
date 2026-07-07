# ---------------------------------------------------------------------------
# ACR Module — Outputs
# ---------------------------------------------------------------------------

output "acr_id" {
  description = "Resource ID of the Container Registry."
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "Name of the Container Registry."
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Login server URL of the Container Registry."
  value       = azurerm_container_registry.this.login_server
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint, if created."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
}
