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
| [azurerm_monitor_action_group.action_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_diagnostic_setting.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.metric_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | Name of the action group for alert notifications. | `string` | `"aks-platform-alerts"` | no |
| <a name="input_aks_cluster_id"></a> [aks\_cluster\_id](#input\_aks\_cluster\_id) | Resource ID of the AKS cluster to monitor. Used for scoping diagnostic settings. | `string` | `null` | no |
| <a name="input_alert_email_receivers"></a> [alert\_email\_receivers](#input\_alert\_email\_receivers) | List of email receivers for the action group. | <pre>list(object({<br/>    name          = string<br/>    email_address = string<br/>  }))</pre> | `[]` | no |
| <a name="input_alert_rules"></a> [alert\_rules](#input\_alert\_rules) | Map of metric alert rules. Key = alert name, value = alert configuration.<br/>Defaults are provided for common AKS alerts if enable\_alerts is true. | <pre>map(object({<br/>    description = string<br/>    severity    = number<br/>    frequency   = optional(string, "PT5M")<br/>    window_size = optional(string, "PT15M")<br/>    criteria = object({<br/>      metric_namespace = string<br/>      metric_name      = string<br/>      aggregation      = string<br/>      operator         = string<br/>      threshold        = number<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_alerts"></a> [enable\_alerts](#input\_enable\_alerts) | Enable metric alert rules for the AKS cluster. | `bool` | `false` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings for the AKS cluster. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for monitoring resources. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Resource ID of the Log Analytics workspace for alert queries. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all monitoring resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | Resource ID of the action group. |
| <a name="output_alert_rule_ids"></a> [alert\_rule\_ids](#output\_alert\_rule\_ids) | Map of alert rule names to their resource IDs. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Resource ID of the AKS diagnostic setting. |
<!-- END_TF_DOCS -->
