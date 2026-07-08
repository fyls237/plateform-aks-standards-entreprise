# ---------------------------------------------------------------------------
# Identities Module — Outputs
# ---------------------------------------------------------------------------

output "identity_ids" {
  description = "Map of identity names to their resource IDs."
  value       = { for k, v in azurerm_user_assigned_identity.assigned_identity : k => v.id }
}

output "identity_principal_ids" {
  description = "Map of identity names to their principal (object) IDs."
  value       = { for k, v in azurerm_user_assigned_identity.assigned_identity : k => v.principal_id }
}

output "identity_client_ids" {
  description = "Map of identity names to their client IDs."
  value       = { for k, v in azurerm_user_assigned_identity.assigned_identity : k => v.client_id }
}

output "identity_tenant_id" {
  description = "Tenant ID of the managed identities."
  value       = length(azurerm_user_assigned_identity.assigned_identity) > 0 ? values(azurerm_user_assigned_identity.assigned_identity)[0].tenant_id : null
}
