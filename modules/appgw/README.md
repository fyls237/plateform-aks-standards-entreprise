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
| [azurerm_application_gateway.agic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_application_gateway.nginx](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_monitor_diagnostic_setting.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_web_application_firewall_policy.waf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscale_max_capacity"></a> [autoscale\_max\_capacity](#input\_autoscale\_max\_capacity) | Maximum capacity for autoscaling. | `number` | `3` | no |
| <a name="input_autoscale_min_capacity"></a> [autoscale\_min\_capacity](#input\_autoscale\_min\_capacity) | Minimum capacity for autoscaling. | `number` | `1` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of User Assigned Managed Identity IDs to assign to the Application Gateway (needed to read from Key Vault). | `list(string)` | `[]` | no |
| <a name="input_ingress_type"></a> [ingress\_type](#input\_ingress\_type) | Type of ingress integration: 'agic' or 'nginx'. | `string` | `"nginx"` | no |
| <a name="input_key_vault_secret_id"></a> [key\_vault\_secret\_id](#input\_key\_vault\_secret\_id) | The Secret ID of the TLS certificate in Key Vault. If provided, configures an HTTPS listener. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for diagnostic settings. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Application Gateway. | `string` | n/a | yes |
| <a name="input_nginx_ilb_ip"></a> [nginx\_ilb\_ip](#input\_nginx\_ilb\_ip) | Private IP address of the NGINX Internal Load Balancer. Required if ingress\_type is 'nginx'. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the Application Gateway will be deployed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources. | `map(string)` | `{}` | no |
| <a name="input_waf_mode"></a> [waf\_mode](#input\_waf\_mode) | WAF policy mode. Options: Detection, Prevention. | `string` | `"Prevention"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_gateway_id"></a> [application\_gateway\_id](#output\_application\_gateway\_id) | Resource ID of the Application Gateway. |
| <a name="output_application_gateway_name"></a> [application\_gateway\_name](#output\_application\_gateway\_name) | Name of the Application Gateway. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address of the Application Gateway. |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Resource ID of the Public IP. |
<!-- END_TF_DOCS -->
