# ---------------------------------------------------------------------------
# Key Vault Module — Variables
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name of the Key Vault. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 characters, alphanumeric and hyphens, starting with a letter."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID for the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "SKU for the Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be 'standard' or 'premium'."
  }
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "Enable purge protection. Cannot be disabled once enabled."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted vaults."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for Key Vault data plane authorization instead of access policies."
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "Network ACL configuration for the Key Vault."
  type = object({
    bypass                     = optional(string, "AzureServices")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

variable "enable_private_endpoint" {
  description = "Create a private endpoint for the Key Vault."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint is true."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for the Key Vault private endpoint. Required when enable_private_endpoint is true."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the Key Vault."
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
