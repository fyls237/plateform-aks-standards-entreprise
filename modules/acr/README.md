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
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Enable admin user. Should be disabled in production; use managed identities instead. | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostic settings for the Container Registry. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for the Container Registry. Requires Premium SKU. | `bool` | `false` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | List of regions for geo-replication. Requires Premium SKU. | <pre>list(object({<br/>    location                = string<br/>    zone_redundancy_enabled = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Container Registry. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure Container Registry. Must be globally unique, alphanumeric only. | `string` | n/a | yes |
| <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set) | Network rule set for the registry. Requires Premium SKU. | <pre>object({<br/>    default_action = optional(string, "Allow")<br/>    ip_rules = optional(list(object({<br/>      action   = string<br/>      ip_range = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS Zone ID for ACR private endpoint. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint is true. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow public network access to the registry. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_retention_policy_days"></a> [retention\_policy\_days](#input\_retention\_policy\_days) | Number of days to retain untagged manifests. Set to 0 to disable. Requires Premium SKU. | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Container Registry. Use Premium for private endpoints and geo-replication. | `string` | `"Premium"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | Enable zone redundancy. Requires Premium SKU. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_id"></a> [acr\_id](#output\_acr\_id) | Resource ID of the Container Registry. |
| <a name="output_acr_login_server"></a> [acr\_login\_server](#output\_acr\_login\_server) | Login server URL of the Container Registry. |
| <a name="output_acr_name"></a> [acr\_name](#output\_acr\_name) | Name of the Container Registry. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Resource ID of the private endpoint, if created. |
<!-- END_TF_DOCS -->
