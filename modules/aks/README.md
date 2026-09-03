## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment.agic_appgw_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | List of Azure AD group object IDs for cluster admin access. | `list(string)` | `[]` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | List of authorized IP ranges to access the API server. Applies only when private\_cluster\_enabled is false. | `list(string)` | `[]` | no |
| <a name="input_appgw_id"></a> [appgw\_id](#input\_appgw\_id) | Resource ID of the Application Gateway for AGIC. Required when ingress\_type is 'agic'. | `string` | `null` | no |
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | Automatic upgrade channel. Options: none, patch, rapid, stable, node-image. | `string` | `"stable"` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Enable Azure Policy for Kubernetes. | `bool` | `true` | no |
| <a name="input_azure_rbac_enabled"></a> [azure\_rbac\_enabled](#input\_azure\_rbac\_enabled) | Enable Azure RBAC for Kubernetes authorization. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the AKS cluster. | `string` | n/a | yes |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Configuration for the default (system) node pool. | <pre>object({<br/>    name                         = optional(string, "system")<br/>    vm_size                      = optional(string, "Standard_D4s_v5")<br/>    node_count                   = optional(number, 3)<br/>    min_count                    = optional(number, 2)<br/>    max_count                    = optional(number, 5)<br/>    auto_scaling_enabled         = optional(bool, true)<br/>    max_pods                     = optional(number, 110)<br/>    os_disk_size_gb              = optional(number, 128)<br/>    os_disk_type                 = optional(string, "Managed")<br/>    os_sku                       = optional(string, "AzureLinux")<br/>    zones                        = optional(list(string), ["1", "2", "3"])<br/>    only_critical_addons_enabled = optional(bool, true)<br/>    temporary_name_for_rotation  = optional(string, "tmpsys")<br/>    upgrade_settings = optional(object({<br/>      max_surge                     = optional(string, "33%")<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>    }), {})<br/>    node_labels = optional(map(string), {})<br/>    tags        = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP address for the Kubernetes DNS service. Must be within service\_cidr. | `string` | `"10.0.0.10"` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Identity type for the AKS cluster. | `string` | `"UserAssigned"` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | Enable image cleaner to remove unused images from nodes. | `bool` | `true` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | Interval in hours for the image cleaner. | `number` | `48` | no |
| <a name="input_ingress_type"></a> [ingress\_type](#input\_ingress\_type) | Type of ingress controller integration: 'none', 'agic', or 'nginx'. | `string` | `"nginx"` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | Enable Azure Key Vault Secrets Provider (CSI driver). | `bool` | `false` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | Kubelet identity configuration. If provided, uses a separate identity for kubelet. | <pre>object({<br/>    client_id                 = string<br/>    object_id                 = string<br/>    user_assigned_identity_id = string<br/>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the cluster. Use 'az aks get-versions' to list available versions. | `string` | `null` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | Disable local Kubernetes admin account. Enforces Azure AD authentication. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the AKS cluster. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for Container Insights. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window configuration for the cluster. | <pre>object({<br/>    allowed = optional(list(object({<br/>      day   = string<br/>      hours = list(number)<br/>    })), [])<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_monitor_metrics_enabled"></a> [monitor\_metrics\_enabled](#input\_monitor\_metrics\_enabled) | Enable Azure Monitor metrics profile. | `bool` | `true` | no |
| <a name="input_network_data_plane"></a> [network\_data\_plane](#input\_network\_data\_plane) | Network data plane. Use 'cilium' for Azure CNI powered by Cilium. | `string` | `null` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin for the cluster. | `string` | `"azure"` | no |
| <a name="input_network_plugin_mode"></a> [network\_plugin\_mode](#input\_network\_plugin\_mode) | Network plugin mode. Use 'overlay' for Azure CNI Overlay. | `string` | `"overlay"` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Network policy provider. Options: azure, calico, cilium. | `string` | `"azure"` | no |
| <a name="input_node_os_upgrade_channel"></a> [node\_os\_upgrade\_channel](#input\_node\_os\_upgrade\_channel) | Node OS upgrade channel. | `string` | `"NodeImage"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Map of additional (user) node pools. Supports general workload pools, memory-optimized pools, and GPU-enabled pools (e.g., Standard\_NC* or Standard\_ND* families) with dedicated node\_taints (e.g. sku=gpu:NoSchedule) and node\_labels. | <pre>map(object({<br/>    vm_size              = optional(string, "Standard_D4s_v5")<br/>    node_count           = optional(number, 1)<br/>    min_count            = optional(number, 1)<br/>    max_count            = optional(number, 10)<br/>    auto_scaling_enabled = optional(bool, true)<br/>    max_pods             = optional(number, 110)<br/>    os_disk_size_gb      = optional(number, 128)<br/>    os_disk_type         = optional(string, "Managed")<br/>    os_sku               = optional(string, "AzureLinux")<br/>    zones                = optional(list(string), ["1", "2", "3"])<br/>    mode                 = optional(string, "User")<br/>    priority             = optional(string, "Regular")<br/>    spot_max_price       = optional(number, -1)<br/>    eviction_policy      = optional(string, "Delete")<br/>    node_labels          = optional(map(string), {})<br/>    node_taints          = optional(list(string), [])<br/>    vnet_subnet_id       = optional(string)<br/>    upgrade_settings = optional(object({<br/>      max_surge                     = optional(string, "33%")<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>    }), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable OIDC issuer for Workload Identity. | `bool` | `true` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | CIDR for pod IP allocation when using CNI Overlay. | `string` | `"10.244.0.0/16"` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Enable private cluster. API server accessible only via private endpoint. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Enable public FQDN for the private cluster (for hybrid scenarios). | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS Zone ID for the private cluster API server. Use 'System' for AKS-managed, 'None' for public, or a zone resource ID. | `string` | `"System"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource ID of the resource group. Used for role assignments. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | CIDR for Kubernetes service IPs. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the AKS cluster. Use 'Standard' for SLA-backed clusters. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all AKS resources. | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | Resource ID of the user-assigned managed identity. Required when identity\_type is 'UserAssigned'. | `string` | `null` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | Subnet ID for the AKS nodes. | `string` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable Workload Identity for pod-level Azure AD authentication. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | FQDN of the AKS cluster API server. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Resource ID of the AKS cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | Identity block of the AKS cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the AKS cluster. |
| <a name="output_host"></a> [host](#output\_host) | Kubernetes API server host. |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | Raw kubeconfig for the AKS cluster. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | Kubelet identity of the AKS cluster. |
| <a name="output_node_pool_ids"></a> [node\_pool\_ids](#output\_node\_pool\_ids) | Map of additional node pool names to their resource IDs. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | Auto-generated resource group for AKS node resources. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | OIDC issuer URL for Workload Identity. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment.agic_appgw_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | List of Azure AD group object IDs for cluster admin access. | `list(string)` | `[]` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | List of authorized IP ranges to access the API server. Applies only when private\_cluster\_enabled is false. | `list(string)` | `[]` | no |
| <a name="input_appgw_id"></a> [appgw\_id](#input\_appgw\_id) | Resource ID of the Application Gateway for AGIC. Required when ingress\_type is 'agic'. | `string` | `null` | no |
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | Automatic upgrade channel. Options: none, patch, rapid, stable, node-image. | `string` | `"stable"` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Enable Azure Policy for Kubernetes. | `bool` | `true` | no |
| <a name="input_azure_rbac_enabled"></a> [azure\_rbac\_enabled](#input\_azure\_rbac\_enabled) | Enable Azure RBAC for Kubernetes authorization. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the AKS cluster. | `string` | n/a | yes |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Configuration for the default (system) node pool. | <pre>object({<br/>    name                         = optional(string, "system")<br/>    vm_size                      = optional(string, "Standard_D4s_v5")<br/>    node_count                   = optional(number, 3)<br/>    min_count                    = optional(number, 2)<br/>    max_count                    = optional(number, 5)<br/>    auto_scaling_enabled         = optional(bool, true)<br/>    max_pods                     = optional(number, 110)<br/>    os_disk_size_gb              = optional(number, 128)<br/>    os_disk_type                 = optional(string, "Managed")<br/>    os_sku                       = optional(string, "AzureLinux")<br/>    zones                        = optional(list(string), ["1", "2", "3"])<br/>    only_critical_addons_enabled = optional(bool, true)<br/>    temporary_name_for_rotation  = optional(string, "tmpsys")<br/>    upgrade_settings = optional(object({<br/>      max_surge                     = optional(string, "33%")<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>    }), {})<br/>    node_labels = optional(map(string), {})<br/>    tags        = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP address for the Kubernetes DNS service. Must be within service\_cidr. | `string` | `"10.0.0.10"` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Identity type for the AKS cluster. | `string` | `"UserAssigned"` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | Enable image cleaner to remove unused images from nodes. | `bool` | `true` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | Interval in hours for the image cleaner. | `number` | `48` | no |
| <a name="input_ingress_type"></a> [ingress\_type](#input\_ingress\_type) | Type of ingress controller integration: 'none', 'agic', or 'nginx'. | `string` | `"nginx"` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | Enable Azure Key Vault Secrets Provider (CSI driver). | `bool` | `false` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | Kubelet identity configuration. If provided, uses a separate identity for kubelet. | <pre>object({<br/>    client_id                 = string<br/>    object_id                 = string<br/>    user_assigned_identity_id = string<br/>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the cluster. Use 'az aks get-versions' to list available versions. | `string` | `null` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | Disable local Kubernetes admin account. Enforces Azure AD authentication. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the AKS cluster. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for Container Insights. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window configuration for the cluster. | <pre>object({<br/>    allowed = optional(list(object({<br/>      day   = string<br/>      hours = list(number)<br/>    })), [])<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_monitor_metrics_enabled"></a> [monitor\_metrics\_enabled](#input\_monitor\_metrics\_enabled) | Enable Azure Monitor metrics profile. | `bool` | `true` | no |
| <a name="input_network_data_plane"></a> [network\_data\_plane](#input\_network\_data\_plane) | Network data plane. Use 'cilium' for Azure CNI powered by Cilium. | `string` | `null` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin for the cluster. | `string` | `"azure"` | no |
| <a name="input_network_plugin_mode"></a> [network\_plugin\_mode](#input\_network\_plugin\_mode) | Network plugin mode. Use 'overlay' for Azure CNI Overlay. | `string` | `"overlay"` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Network policy provider. Options: azure, calico, cilium. | `string` | `"azure"` | no |
| <a name="input_node_os_upgrade_channel"></a> [node\_os\_upgrade\_channel](#input\_node\_os\_upgrade\_channel) | Node OS upgrade channel. | `string` | `"NodeImage"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Map of additional (user) node pools. Supports general workload pools, memory-optimized pools, and GPU-enabled pools (e.g., Standard\_NC* or Standard\_ND* families) with dedicated node\_taints (e.g. sku=gpu:NoSchedule) and node\_labels. | <pre>map(object({<br/>    vm_size              = optional(string, "Standard_D4s_v5")<br/>    node_count           = optional(number, 1)<br/>    min_count            = optional(number, 1)<br/>    max_count            = optional(number, 10)<br/>    auto_scaling_enabled = optional(bool, true)<br/>    max_pods             = optional(number, 110)<br/>    os_disk_size_gb      = optional(number, 128)<br/>    os_disk_type         = optional(string, "Managed")<br/>    os_sku               = optional(string, "AzureLinux")<br/>    zones                = optional(list(string), ["1", "2", "3"])<br/>    mode                 = optional(string, "User")<br/>    priority             = optional(string, "Regular")<br/>    spot_max_price       = optional(number, -1)<br/>    eviction_policy      = optional(string, "Delete")<br/>    node_labels          = optional(map(string), {})<br/>    node_taints          = optional(list(string), [])<br/>    vnet_subnet_id       = optional(string)<br/>    upgrade_settings = optional(object({<br/>      max_surge                     = optional(string, "33%")<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>    }), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable OIDC issuer for Workload Identity. | `bool` | `true` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | CIDR for pod IP allocation when using CNI Overlay. | `string` | `"10.244.0.0/16"` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Enable private cluster. API server accessible only via private endpoint. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Enable public FQDN for the private cluster (for hybrid scenarios). | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS Zone ID for the private cluster API server. Use 'System' for AKS-managed, 'None' for public, or a zone resource ID. | `string` | `"System"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource ID of the resource group. Used for role assignments. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | CIDR for Kubernetes service IPs. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the AKS cluster. Use 'Standard' for SLA-backed clusters. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all AKS resources. | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | Resource ID of the user-assigned managed identity. Required when identity\_type is 'UserAssigned'. | `string` | `null` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | Subnet ID for the AKS nodes. | `string` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable Workload Identity for pod-level Azure AD authentication. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | FQDN of the AKS cluster API server. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Resource ID of the AKS cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | Identity block of the AKS cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the AKS cluster. |
| <a name="output_host"></a> [host](#output\_host) | Kubernetes API server host. |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | Raw kubeconfig for the AKS cluster. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | Kubelet identity of the AKS cluster. |
| <a name="output_node_pool_ids"></a> [node\_pool\_ids](#output\_node\_pool\_ids) | Map of additional node pool names to their resource IDs. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | Auto-generated resource group for AKS node resources. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | OIDC issuer URL for Workload Identity. |
<!-- END_TF_DOCS -->
