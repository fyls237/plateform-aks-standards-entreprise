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
| [azurerm_resource_group_policy_assignment.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.compliance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.deny_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_security_center_subscription_pricing.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_security_center_subscription_pricing.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_security_center_subscription_pricing.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_policy_definition.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.not_allowed_resources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_locations"></a> [allowed\_locations](#input\_allowed\_locations) | List of allowed Azure regions to enforce Data Sovereignty (e.g., ['westeurope', 'francecentral']). | `list(string)` | <pre>[<br/>  "westeurope"<br/>]</pre> | no |
| <a name="input_compliance_initiative_ids"></a> [compliance\_initiative\_ids](#input\_compliance\_initiative\_ids) | List of built-in Azure Policy Initiative IDs to assign. Using IDs is more stable than display names. | `list(string)` | <pre>[<br/>  "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"<br/>]</pre> | no |
| <a name="input_deny_public_ip_enabled"></a> [deny\_public\_ip\_enabled](#input\_deny\_public\_ip\_enabled) | If true, assigns a policy to deny the creation of Public IPs in the Resource Group. | `bool` | `true` | no |
| <a name="input_enable_subscription_defender_plans"></a> [enable\_subscription\_defender\_plans](#input\_enable\_subscription\_defender\_plans) | If true, attempts to enable Defender for Cloud plans at the Subscription level (requires Sub Owner/Security Admin). If false, only applies RG-level policies and cluster-level Defender. | `bool` | `false` | no |
| <a name="input_exempt_public_ip_ids"></a> [exempt\_public\_ip\_ids](#input\_exempt\_public\_ip\_ids) | List of Public IP Resource IDs that are exempt from the Deny Public IP policy (e.g., AppGW, Bastion). | `list(string)` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the resources. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the Resource Group where policies will be assigned. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
