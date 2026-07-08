# ---------------------------------------------------------------------------
# Networking Module — Variables
# ---------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the resource group where networking resources will be created."
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region for all networking resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,62}[a-zA-Z0-9_]$", var.vnet_name))
    error_message = "VNet name must be 2-64 characters and match Azure naming rules."
  }
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network in CIDR notation."
  type        = list(string)

  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "At least one address space must be provided."
  }
}

variable "subnets" {
  description = <<-EOT
    Map of subnets to create. Each subnet supports:
    - address_prefixes: List of CIDR ranges
    - service_endpoints: Optional list of service endpoints
    - delegation: Optional service delegation block
    - private_endpoint_network_policies: Enable/disable private endpoint policies
  EOT
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Disabled")
    private_link_service_network_policies_enabled = optional(bool, false)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be defined."
  }
}

variable "network_security_groups" {
  description = <<-EOT
    Map of Network Security Groups to create and associate with subnets.
    Key = NSG name, value = object with subnet_key and security rules.
  EOT
  type = map(object({
    subnet_key = string
    rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string)
      destination_port_ranges    = optional(list(string))
      source_address_prefix      = optional(string)
      source_address_prefixes    = optional(list(string))
      destination_address_prefix = optional(string, "*")
    })), [])
  }))
  default = {}
}

variable "route_tables" {
  description = <<-EOT
    Map of route tables to create and associate with subnets.
    Key = route table name, value = object with subnet_key and routes.
  EOT
  type = map(object({
    subnet_key                    = string
    disable_bgp_route_propagation = optional(bool, false)
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), [])
  }))
  default = {}
}

variable "dns_servers" {
  description = "Custom DNS servers for the Virtual Network. Leave empty to use Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for NSG flow logs."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings. Required when enable_diagnostics is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all networking resources."
  type        = map(string)
  default     = {}
}
