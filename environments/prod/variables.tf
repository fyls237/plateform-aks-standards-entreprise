# ---------------------------------------------------------------------------
# Dev Environment — Variables
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

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
