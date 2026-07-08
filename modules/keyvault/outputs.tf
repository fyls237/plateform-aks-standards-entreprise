# ---------------------------------------------------------------------------
# Key Vault Module — Outputs
# ---------------------------------------------------------------------------

output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.key_vault.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint, if created."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.private_endpoint[0].id : null
}

output "private_endpoint_ip" {
  description = "Private IP address of the private endpoint, if created."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.private_endpoint[0].private_service_connection[0].private_ip_address : null
}
