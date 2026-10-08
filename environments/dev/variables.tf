# ---------------------------------------------------------------------------
# Dev Environment — Variables
# ---------------------------------------------------------------------------

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name used in resource naming."
  type        = string
  default     = "aksplatform"
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for AKS cluster admin access."
  type        = list(string)
  default     = []
}

variable "api_server_authorized_ip_ranges" {
  description = "Corporate VPN and administration egress CIDRs allowed to access the public AKS API."
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet. Leave empty to use Azure-provided DNS in dev."
  type        = list(string)
  default     = []
}

variable "alert_email_receivers" {
  description = "Email receivers for monitoring alerts."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to merge with default tags."
  type        = map(string)
  default     = {}
}
