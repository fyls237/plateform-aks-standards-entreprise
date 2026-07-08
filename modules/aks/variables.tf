# ---------------------------------------------------------------------------
# AKS Module — Variables
# ---------------------------------------------------------------------------

# ---- Cluster Identity ----

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,61}[a-zA-Z0-9]$", var.cluster_name))
    error_message = "Cluster name must be 2-63 characters, alphanumeric, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group. Used for role assignments."
  type        = string
}

# ---- Kubernetes Version ----

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster. Use 'az aks get-versions' to list available versions."
  type        = string
  default     = null
}

variable "automatic_upgrade_channel" {
  description = "Automatic upgrade channel. Options: none, patch, rapid, stable, node-image."
  type        = string
  default     = "stable"

  validation {
    condition     = contains(["none", "patch", "rapid", "stable", "node-image"], var.automatic_upgrade_channel)
    error_message = "Upgrade channel must be one of: none, patch, rapid, stable, node-image."
  }
}

# ---- Networking ----

variable "network_plugin" {
  description = "Network plugin for the cluster."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet", "none"], var.network_plugin)
    error_message = "Network plugin must be one of: azure, kubenet, none."
  }
}

variable "network_plugin_mode" {
  description = "Network plugin mode. Use 'overlay' for Azure CNI Overlay."
  type        = string
  default     = "overlay"

  validation {
    condition     = var.network_plugin_mode == null || contains(["overlay"], var.network_plugin_mode)
    error_message = "Network plugin mode must be 'overlay' or null."
  }
}

variable "network_policy" {
  description = "Network policy provider. Options: azure, calico, cilium."
  type        = string
  default     = "azure"

  validation {
    condition     = var.network_policy == null || contains(["azure", "calico", "cilium"], var.network_policy)
    error_message = "Network policy must be one of: azure, calico, cilium."
  }
}

variable "network_data_plane" {
  description = "Network data plane. Use 'cilium' for Azure CNI powered by Cilium."
  type        = string
  default     = null

  validation {
    condition     = var.network_data_plane == null || contains(["azure", "cilium"], var.network_data_plane)
    error_message = "Network data plane must be 'azure' or 'cilium'."
  }
}

variable "pod_cidr" {
  description = "CIDR for pod IP allocation when using CNI Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes service IPs."
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for the Kubernetes DNS service. Must be within service_cidr."
  type        = string
  default     = "10.0.0.10"
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS nodes."
  type        = string
}

# ---- Private Cluster ----

variable "private_cluster_enabled" {
  description = "Enable private cluster. API server accessible only via private endpoint."
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for the private cluster API server. Use 'System' for AKS-managed, 'None' for public, or a zone resource ID."
  type        = string
  default     = "System"
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Enable public FQDN for the private cluster (for hybrid scenarios)."
  type        = bool
  default     = false
}

# ---- Identity ----

variable "identity_type" {
  description = "Identity type for the AKS cluster."
  type        = string
  default     = "UserAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Identity type must be 'SystemAssigned' or 'UserAssigned'."
  }
}

variable "user_assigned_identity_id" {
  description = "Resource ID of the user-assigned managed identity. Required when identity_type is 'UserAssigned'."
  type        = string
  default     = null
}

variable "kubelet_identity" {
  description = "Kubelet identity configuration. If provided, uses a separate identity for kubelet."
  type = object({
    client_id                 = string
    object_id                 = string
    user_assigned_identity_id = string
  })
  default = null
}

# ---- RBAC & Auth ----

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization."
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "Disable local Kubernetes admin account. Enforces Azure AD authentication."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer for Workload Identity."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable Workload Identity for pod-level Azure AD authentication."
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admin access."
  type        = list(string)
  default     = []
}

# ---- Default (System) Node Pool ----

variable "default_node_pool" {
  description = "Configuration for the default (system) node pool."
  type = object({
    name                         = optional(string, "system")
    vm_size                      = optional(string, "Standard_D4s_v5")
    node_count                   = optional(number, 3)
    min_count                    = optional(number, 2)
    max_count                    = optional(number, 5)
    auto_scaling_enabled         = optional(bool, true)
    max_pods                     = optional(number, 110)
    os_disk_size_gb              = optional(number, 128)
    os_disk_type                 = optional(string, "Managed")
    os_sku                       = optional(string, "AzureLinux")
    zones                        = optional(list(string), ["1", "2", "3"])
    only_critical_addons_enabled = optional(bool, true)
    temporary_name_for_rotation  = optional(string, "tmpsys")
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "33%")
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
    node_labels = optional(map(string), {})
    tags        = optional(map(string), {})
  })
  default = {}
}

# ---- Additional Node Pools ----

variable "node_pools" {
  description = "Map of additional (user) node pools."
  type = map(object({
    vm_size              = optional(string, "Standard_D4s_v5")
    node_count           = optional(number, 1)
    min_count            = optional(number, 1)
    max_count            = optional(number, 10)
    auto_scaling_enabled = optional(bool, true)
    max_pods             = optional(number, 110)
    os_disk_size_gb      = optional(number, 128)
    os_disk_type         = optional(string, "Managed")
    os_sku               = optional(string, "AzureLinux")
    zones                = optional(list(string), ["1", "2", "3"])
    mode                 = optional(string, "User")
    priority             = optional(string, "Regular")
    spot_max_price       = optional(number, -1)
    eviction_policy      = optional(string, "Delete")
    node_labels          = optional(map(string), {})
    node_taints          = optional(list(string), [])
    vnet_subnet_id       = optional(string)
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "33%")
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ---- Monitoring ----

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Container Insights."
  type        = string
  default     = null
}

variable "monitor_metrics_enabled" {
  description = "Enable Azure Monitor metrics profile."
  type        = bool
  default     = true
}

# ---- Maintenance ----

variable "maintenance_window" {
  description = "Maintenance window configuration for the cluster."
  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })), [])
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
}

# ---- Misc ----

variable "sku_tier" {
  description = "SKU tier for the AKS cluster. Use 'Standard' for SLA-backed clusters."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be one of: Free, Standard, Premium."
  }
}

variable "node_os_upgrade_channel" {
  description = "Node OS upgrade channel."
  type        = string
  default     = "NodeImage"

  validation {
    condition     = contains(["None", "Unmanaged", "SecurityPatch", "NodeImage"], var.node_os_upgrade_channel)
    error_message = "Node OS upgrade channel must be one of: None, Unmanaged, SecurityPatch, NodeImage."
  }
}

variable "image_cleaner_enabled" {
  description = "Enable image cleaner to remove unused images from nodes."
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  description = "Interval in hours for the image cleaner."
  type        = number
  default     = 48
}

variable "tags" {
  description = "Tags to apply to all AKS resources."
  type        = map(string)
  default     = {}
}
