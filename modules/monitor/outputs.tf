# ---------------------------------------------------------------------------
# Monitor Module — Outputs
# ---------------------------------------------------------------------------

output "action_group_id" {
  description = "Resource ID of the action group."
  value       = var.enable_alerts ? azurerm_monitor_action_group.action_group[0].id : null
}

output "diagnostic_setting_id" {
  description = "Resource ID of the AKS diagnostic setting."
  value       = var.enable_diagnostic_settings && var.aks_cluster_id != null ? azurerm_monitor_diagnostic_setting.aks[0].id : null
}

output "alert_rule_ids" {
  description = "Map of alert rule names to their resource IDs."
  value       = { for k, v in azurerm_monitor_metric_alert.metric_alert : k => v.id }
}
