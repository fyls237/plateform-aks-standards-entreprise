# ---------------------------------------------------------------------------
# Identities Module — Variables
# ---------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for identity resources."
  type        = string
}

variable "managed_identities" {
  description = <<-EOT
    Map of user-assigned managed identities to create.
    Key = identity name, value = optional configuration.
  EOT
  type = map(object({
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "role_assignments" {
  description = <<-EOT
    List of role assignments to create for the managed identities.
    Each entry maps an identity (by key) to a role and scope.
  EOT
  type = list(object({
    identity_key         = string
    role_definition_name = string
    scope                = string
  }))
  default = []
}

variable "federated_identity_credentials" {
  description = <<-EOT
    List of federated identity credentials for Workload Identity.
    Maps a managed identity to a Kubernetes service account via OIDC.
  EOT
  type = list(object({
    name         = string
    identity_key = string
    issuer       = string
    subject      = string
    audiences    = optional(list(string), ["api://AzureADTokenExchange"])
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all identity resources."
  type        = map(string)
  default     = {}
}
