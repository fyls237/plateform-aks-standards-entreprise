# ---------------------------------------------------------------------------
# Preprod Environment — Variables
# ---------------------------------------------------------------------------

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "preprod"
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

# ---------------------------------------------------------------------------
# Hub & Spoke Integration (optional)
# ---------------------------------------------------------------------------

variable "hub_vnet_id" {
  description = "Resource ID of the Hub VNet for peering. Leave null for standalone deployments."
  type        = string
  default     = null
}

variable "hub_vnet_name" {
  description = "Name of the Hub VNet."
  type        = string
  default     = null
}

variable "hub_vnet_resource_group_name" {
  description = "Resource group of the Hub VNet."
  type        = string
  default     = null
}

variable "hub_subscription_id" {
  description = "Subscription ID of the Hub VNet. Leave null if same subscription."
  type        = string
  default     = null
}

variable "hub_firewall_private_ip" {
  description = "Private IP address of the Hub's Azure Firewall."
  type        = string
  default     = null
}
