# Security Exceptions

This register documents the active Checkov suppressions in Terraform. Exceptions are narrowly scoped to the listed resources and must be reviewed by 2026-12-31.

| Module and Checkov check | Scope and justification | Compensating controls | Review date |
|---|---|---|---|
| `modules/bastion` - `CKV_AZURE_50` | Suppressed on the jumphost VM and its VM extension because the `AADSSHLoginForLinux` extension provides keyless Microsoft Entra SSH authentication. | The VM has no public IP, password authentication is disabled, inbound access is through Azure Bastion, and login is controlled by the `Virtual Machine Administrator Login` role. Reassess whether the check can be satisfied without suppressing it. | 2026-12-31 |
| `modules/appgw` - `CKV_AZURE_118` | Suppressed on the AGIC-managed and Terraform-managed Application Gateways. The module's existing annotation records TLS certificate integration as pending for the base configuration. | The module supports a Key Vault certificate via `key_vault_secret_id`; HTTPS is configured when that value is supplied. Confirm it is supplied for production deployments and remove the suppression when the base configuration guarantees TLS. | 2026-12-31 |
| `modules/appgw` - `CKV_AZURE_218` | Suppressed on the AGIC-managed and Terraform-managed Application Gateways because the HTTP listener is used as a placeholder; AGIC manages listener configuration for AGIC deployments. | For Terraform-managed deployments, HTTPS is configured when `key_vault_secret_id` is supplied. Confirm production listener configuration and remove the suppression when HTTP is no longer a permitted default. | 2026-12-31 |

These suppressions bypass Checkov for the annotated controls. They do not suppress Trivy findings. New exceptions require a documented rationale, compensating controls, and an explicit review date; HIGH/CRITICAL findings must not be made non-blocking through workflow-wide settings.
