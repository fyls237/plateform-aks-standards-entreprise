# ---------------------------------------------------------------------------
# Private Endpoint Submodule — Variables
# ---------------------------------------------------------------------------

variable "enabled" {
  description = "Whether to create the private endpoint. When false, no resources are created."
  type        = bool
  default     = true
}

variable "name" {
  description = "Base name used to derive the private endpoint and private service connection names (e.g. '<name>-pe', '<name>-psc')."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the private endpoint."
  type        = string
}

variable "location" {
  description = "Azure region for the private endpoint."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID in which to create the private endpoint. Required when enabled is true."
  type        = string
  default     = null
}

variable "private_connection_resource_id" {
  description = "Resource ID of the target resource (e.g. ACR, Key Vault, Storage Account) the private endpoint connects to."
  type        = string
  default     = null
}

variable "subresource_names" {
  description = "List of subresource names (groupIds) for the private service connection, e.g. ['registry'], ['vault'], ['blob']."
  type        = list(string)
  default     = []
}

variable "is_manual_connection" {
  description = "Whether the private service connection requires manual approval."
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "List of Private DNS Zone IDs to associate via a private_dns_zone_group. If empty, no DNS zone group is created."
  type        = list(string)
  default     = []
}

variable "private_dns_zone_group_name" {
  description = "Name of the private_dns_zone_group block."
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags to apply to the private endpoint."
  type        = map(string)
  default     = {}
}
