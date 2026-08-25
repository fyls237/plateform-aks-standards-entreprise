variable "name_prefix" {
  description = "Prefix for the resources."
  type        = string
}

variable "resource_group_id" {
  description = "The ID of the Resource Group where policies will be assigned."
  type        = string
}

variable "compliance_initiative_ids" {
  description = "List of built-in Azure Policy Initiative IDs to assign. Using IDs is more stable than display names."
  type        = list(string)
  default     = ["/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"]
}

variable "deny_public_ip_enabled" {
  description = "If true, assigns a policy to deny the creation of Public IPs in the Resource Group."
  type        = bool
  default     = true
}

variable "exempt_public_ip_ids" {
  description = "List of Public IP Resource IDs that are exempt from the Deny Public IP policy (e.g., AppGW, Bastion)."
  type        = list(string)
  default     = []
}

variable "allowed_locations" {
  description = "List of allowed Azure regions to enforce Data Sovereignty (e.g., ['westeurope', 'francecentral'])."
  type        = list(string)
  default     = ["westeurope"]
}

variable "enable_subscription_defender_plans" {
  description = "If true, attempts to enable Defender for Cloud plans at the Subscription level (requires Sub Owner/Security Admin). If false, only applies RG-level policies and cluster-level Defender."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
