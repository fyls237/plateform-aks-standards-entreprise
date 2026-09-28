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
| [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the private endpoint. When false, no resources are created. | `bool` | `true` | no |
| <a name="input_is_manual_connection"></a> [is\_manual\_connection](#input\_is\_manual\_connection) | Whether the private service connection requires manual approval. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the private endpoint. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name used to derive the private endpoint and private service connection names (e.g. '<name>-pe', '<name>-psc'). | `string` | n/a | yes |
| <a name="input_private_connection_resource_id"></a> [private\_connection\_resource\_id](#input\_private\_connection\_resource\_id) | Resource ID of the target resource (e.g. ACR, Key Vault, Storage Account) the private endpoint connects to. | `string` | `null` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Name of the private\_dns\_zone\_group block. | `string` | `"default"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | List of Private DNS Zone IDs to associate via a private\_dns\_zone\_group. If empty, no DNS zone group is created. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group in which to create the private endpoint. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID in which to create the private endpoint. Required when enabled is true. | `string` | `null` | no |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | List of subresource names (groupIds) for the private service connection, e.g. ['registry'], ['vault'], ['blob']. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the private endpoint. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the private endpoint, or null if not created. |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | Resource ID of the network interface created for the private endpoint, or null if not created. |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address assigned to the private endpoint's NIC, or null if not created. |
<!-- END_TF_DOCS -->
