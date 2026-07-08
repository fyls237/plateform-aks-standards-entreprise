# ---------------------------------------------------------------------------
# Log Analytics Module — Variables
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name of the Log Analytics workspace."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{2,61}[a-zA-Z0-9]$", var.name))
    error_message = "Workspace name must be 4-63 characters, alphanumeric and hyphens, starting and ending with alphanumeric."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
}

variable "sku" {
  description = "SKU for the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerGB2018", "PerNode", "Premium", "Standard", "Standalone"], var.sku)
    error_message = "SKU must be one of: Free, PerGB2018, PerNode, Premium, Standard, Standalone."
  }
}

variable "retention_in_days" {
  description = "Data retention period in days. Free tier supports 7 days only."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 7 && var.retention_in_days <= 730
    error_message = "Retention must be between 7 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB. Use -1 for unlimited."
  type        = number
  default     = -1
}

variable "enable_container_insights" {
  description = "Deploy the ContainerInsights solution for AKS monitoring."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
