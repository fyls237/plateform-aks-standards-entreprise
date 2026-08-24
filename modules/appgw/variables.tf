# ---------------------------------------------------------------------------
# Application Gateway Module — Variables
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name of the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the Application Gateway will be deployed."
  type        = string
}

variable "ingress_type" {
  description = "Type of ingress integration: 'agic' or 'nginx'."
  type        = string
  default     = "nginx"

  validation {
    condition     = contains(["agic", "nginx"], var.ingress_type)
    error_message = "ingress_type must be either 'agic' or 'nginx'."
  }
}

variable "nginx_ilb_ip" {
  description = "Private IP address of the NGINX Internal Load Balancer. Required if ingress_type is 'nginx'."
  type        = string
  default     = null
}

variable "waf_mode" {
  description = "WAF policy mode. Options: Detection, Prevention."
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be either 'Detection' or 'Prevention'."
  }
}

variable "autoscale_min_capacity" {
  description = "Minimum capacity for autoscaling."
  type        = number
  default     = 1
}

variable "autoscale_max_capacity" {
  description = "Maximum capacity for autoscaling."
  type        = number
  default     = 3
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "key_vault_secret_id" {
  description = "The Secret ID of the TLS certificate in Key Vault. If provided, configures an HTTPS listener."
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "List of User Assigned Managed Identity IDs to assign to the Application Gateway (needed to read from Key Vault)."
  type        = list(string)
  default     = []
}
