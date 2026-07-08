# ---------------------------------------------------------------------------
# AKS Module — Main
# Enterprise AKS Cluster with CNI Overlay, Workload Identity, Azure RBAC
# ---------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "this" {
  name                       = var.cluster_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  dns_prefix                 = var.private_cluster_enabled ? null : var.cluster_name
  dns_prefix_private_cluster = var.private_cluster_enabled ? var.cluster_name : null
  kubernetes_version         = var.kubernetes_version

  # SKU & Upgrades
  sku_tier                     = var.sku_tier
  automatic_upgrade_channel    = var.automatic_upgrade_channel
  node_os_upgrade_channel      = var.node_os_upgrade_channel
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  # Private Cluster
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_cluster_enabled ? var.private_dns_zone_id : null
  private_cluster_public_fqdn_enabled = var.private_cluster_enabled ? var.private_cluster_public_fqdn_enabled : null

  # RBAC & Auth
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = var.azure_rbac_enabled
    admin_group_object_ids = var.admin_group_object_ids
  }

  local_account_disabled    = var.local_account_disabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  # Identity
  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? [var.user_assigned_identity_id] : null
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [var.kubelet_identity] : []

    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }

  # Networking
  network_profile {
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin == "azure" ? var.network_plugin_mode : null
    network_policy      = var.network_policy
    network_data_plane  = var.network_data_plane
    pod_cidr            = var.network_plugin_mode == "overlay" ? var.pod_cidr : null
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  # Default (System) Node Pool
  default_node_pool {
    name                         = var.default_node_pool.name
    vm_size                      = var.default_node_pool.vm_size
    node_count                   = var.default_node_pool.auto_scaling_enabled ? null : var.default_node_pool.node_count
    min_count                    = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.min_count : null
    max_count                    = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.max_count : null
    auto_scaling_enabled         = var.default_node_pool.auto_scaling_enabled
    max_pods                     = var.default_node_pool.max_pods
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    os_sku                       = var.default_node_pool.os_sku
    zones                        = var.default_node_pool.zones
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    temporary_name_for_rotation  = var.default_node_pool.temporary_name_for_rotation
    vnet_subnet_id               = var.vnet_subnet_id
    node_labels                  = var.default_node_pool.node_labels
    upgrade_settings {
      max_surge                     = var.default_node_pool.upgrade_settings.max_surge
      drain_timeout_in_minutes      = var.default_node_pool.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.default_node_pool.upgrade_settings.node_soak_duration_in_minutes
    }

    tags = merge(var.tags, var.default_node_pool.tags)
  }

  # Monitoring
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics_enabled ? [1] : []

    content {}
  }

  # Maintenance
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []

    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed

        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed

        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

# ---------------------------------------------------------------------------
# Additional Node Pools
# ---------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.auto_scaling_enabled ? null : each.value.node_count
  min_count             = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count             = each.value.auto_scaling_enabled ? each.value.max_count : null
  auto_scaling_enabled  = each.value.auto_scaling_enabled
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  os_sku                = each.value.os_sku
  zones                 = each.value.zones
  mode                  = each.value.mode
  priority              = each.value.priority
  spot_max_price        = each.value.priority == "Spot" ? each.value.spot_max_price : null
  eviction_policy       = each.value.priority == "Spot" ? each.value.eviction_policy : null
  vnet_subnet_id        = coalesce(each.value.vnet_subnet_id, var.vnet_subnet_id)
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  upgrade_settings {
    max_surge                     = each.value.upgrade_settings.max_surge
    drain_timeout_in_minutes      = each.value.upgrade_settings.drain_timeout_in_minutes
    node_soak_duration_in_minutes = each.value.upgrade_settings.node_soak_duration_in_minutes
  }

  tags = merge(var.tags, each.value.tags)

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}

# ---------------------------------------------------------------------------
# Role Assignment — Grant cluster identity rights over node resource group
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "cluster_rg_contributor" {
  count = var.identity_type == "UserAssigned" ? 1 : 0

  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}
