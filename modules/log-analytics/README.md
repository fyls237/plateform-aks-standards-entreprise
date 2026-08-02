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
| [azurerm_log_analytics_solution.container_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | Daily ingestion quota in GB. Use -1 for unlimited. | `number` | `-1` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Deploy the ContainerInsights solution for AKS monitoring. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the workspace. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Log Analytics workspace. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Data retention period in days. Free tier supports 7 days only. | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Log Analytics workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | Primary shared key for the workspace. |
| <a name="output_workspace_customer_id"></a> [workspace\_customer\_id](#output\_workspace\_customer\_id) | Workspace (customer) ID used for agent configuration. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Resource ID of the Log Analytics workspace. |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | Name of the Log Analytics workspace. |
<!-- END_TF_DOCS -->
