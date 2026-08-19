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

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan to attach to the Virtual Network."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for NSG flow logs."
  type        = bool
  default     = false
}

variable "enable_vnet_diagnostics" {
  description = "Enable diagnostic settings for the Virtual Network. Requires log_analytics_workspace_id to be set."
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

# ---------------------------------------------------------------------------
# Hub & Spoke Integration (optional)
# ---------------------------------------------------------------------------

variable "hub_vnet_id" {
  description = "Resource ID of the Hub VNet. Enables VNet peering when set."
  type        = string
  default     = null
}

variable "hub_vnet_name" {
  description = "Name of the Hub VNet. Required when hub_vnet_id is set."
  type        = string
  default     = null
}

variable "hub_vnet_resource_group_name" {
  description = "Resource group name of the Hub VNet. Required when hub_vnet_id is set."
  type        = string
  default     = null
}

variable "hub_subscription_id" {
  description = "Subscription ID of the Hub VNet for cross-subscription peering. Leave null to use the current subscription."
  type        = string
  default     = null
}

variable "hub_use_remote_gateways" {
  description = "If true, the Spoke will use the Hub's gateways (ExpressRoute/VPN). Requires a gateway deployed in the Hub VNet."
  type        = bool
  default     = false
}

variable "hub_allow_gateway_transit" {
  description = "If true, allows the Hub VNet to use this Spoke's gateway. Typically true on the Hub side for gateway transit."
  type        = bool
  default     = false
}

variable "hub_firewall_private_ip" {
  description = "Private IP address of the Hub's Azure Firewall. Enables egress UDR when set."
  type        = string
  default     = null

  validation {
    condition     = var.hub_firewall_private_ip == null || can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.hub_firewall_private_ip))
    error_message = "hub_firewall_private_ip must be a valid IPv4 address."
  }
}

variable "hub_egress_subnet_keys" {
  description = "List of subnet keys to associate with the Hub egress route table. Must not overlap with subnets already defined in var.route_tables."
  type        = list(string)
  default     = ["snet-aks-nodes"]
}

variable "hub_additional_routes" {
  description = "Additional routes to add to the Hub egress route table alongside the default 0.0.0.0/0 route."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}
