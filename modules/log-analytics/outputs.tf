# ---------------------------------------------------------------------------
# Log Analytics Module — Outputs
# ---------------------------------------------------------------------------

output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.workspace.name
}

output "workspace_customer_id" {
  description = "Workspace (customer) ID used for agent configuration."
  value       = azurerm_log_analytics_workspace.workspace.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key for the workspace."
  value       = azurerm_log_analytics_workspace.workspace.primary_shared_key
  sensitive   = true
}
