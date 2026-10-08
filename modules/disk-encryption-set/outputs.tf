output "id" {
  description = "Resource ID of the Disk Encryption Set."
  value       = azurerm_disk_encryption_set.this.id
}

output "key_id" {
  description = "Versionless resource ID of the customer-managed key."
  value       = azurerm_key_vault_key.this.resource_versionless_id
}

output "principal_id" {
  description = "Principal ID of the Disk Encryption Set managed identity."
  value       = azurerm_disk_encryption_set.this.identity[0].principal_id
}
