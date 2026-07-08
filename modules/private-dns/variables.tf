# ---------------------------------------------------------------------------
# Private DNS Module — Variables
# ---------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "dns_zones" {
  description = <<-EOT
    Map of Private DNS zones to create.
    Key = zone name (e.g., "privatelink.azurecr.io"), value = configuration.
  EOT
  type = map(object({
    vnet_links = optional(list(object({
      name                 = string
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
    })), [])
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
