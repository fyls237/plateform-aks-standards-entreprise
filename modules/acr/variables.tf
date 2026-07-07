# ---------------------------------------------------------------------------
# ACR Module — Variables
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name of the Azure Container Registry. Must be globally unique, alphanumeric only."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "ACR name must be 5-50 alphanumeric characters (no hyphens or underscores)."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Container Registry."
  type        = string
}

variable "sku" {
  description = "SKU for the Container Registry. Use Premium for private endpoints and geo-replication."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user. Should be disabled in production; use managed identities instead."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the registry."
  type        = bool
  default     = true
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy. Requires Premium SKU."
  type        = bool
  default     = false
}

variable "retention_policy_days" {
  description = "Number of days to retain untagged manifests. Set to 0 to disable. Requires Premium SKU."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_policy_days >= 0 && var.retention_policy_days <= 365
    error_message = "Retention must be between 0 and 365 days."
  }
}

variable "georeplications" {
  description = "List of regions for geo-replication. Requires Premium SKU."
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default = []
}

variable "network_rule_set" {
  description = "Network rule set for the registry. Requires Premium SKU."
  type = object({
    default_action = optional(string, "Allow")
    ip_rules = optional(list(object({
      action   = string
      ip_range = string
    })), [])
  })
  default = null
}

variable "enable_private_endpoint" {
  description = "Create a private endpoint for the Container Registry. Requires Premium SKU."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint is true."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for ACR private endpoint."
  type        = string
  default     = null
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS kubelet identity. Used to grant AcrPull role."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the Container Registry."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
