# ---------------------------------------------------------------------------
# Monitor Module — Variables
# ---------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for alert queries."
  type        = string
}

variable "aks_cluster_id" {
  description = "Resource ID of the AKS cluster to monitor. Used for scoping diagnostic settings."
  type        = string
  default     = null
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Enable metric alert rules for the AKS cluster."
  type        = bool
  default     = false
}

variable "action_group_name" {
  description = "Name of the action group for alert notifications."
  type        = string
  default     = "aks-platform-alerts"
}

variable "alert_email_receivers" {
  description = "List of email receivers for the action group."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "alert_rules" {
  description = <<-EOT
    Map of metric alert rules. Key = alert name, value = alert configuration.
    Defaults are provided for common AKS alerts if enable_alerts is true.
  EOT
  type = map(object({
    description = string
    severity    = number
    frequency   = optional(string, "PT5M")
    window_size = optional(string, "PT15M")
    criteria = object({
      metric_namespace = string
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = number
    })
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all monitoring resources."
  type        = map(string)
  default     = {}
}
