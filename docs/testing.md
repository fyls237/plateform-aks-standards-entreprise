# Terraform Testing Strategy

The repository uses native `terraform test` unit tests with mocked AzureRM providers. The tests run without Azure credentials, an Azure subscription, or a remote state backend.

## Current PR test suite

Tests live under `tests/` and execute the module directly through a test `module` block:

| Test | Coverage |
|------|----------|
| `tests/unit/governance` | Compliance, deny-public-IP, allowed-location policy assignments and parameters |
| `tests/unit/aks` | Azure RBAC, disabled local account, and private cluster settings |
| `tests/unit/networking` | Default-deny inbound NSG rule and subnet association |

Each fixture contains only a `.tftest.hcl` file. Its `run` block uses `module.source` to load the module under test, supplies variables locally, and asserts directly against the module resources. The `azurerm` provider is mocked and all runs use `command = plan`.

Run the complete suite from the repository root:

```bash
make test
```

Run one fixture while developing:

```bash
terraform -chdir=tests/unit/governance init -backend=false -input=false
terraform -chdir=tests/unit/governance test -verbose
```

The `Terraform Tests` CI job runs all three fixtures on every pull request and push to `main`. Any assertion or Terraform error fails the job.

## Why plan and mocks

`command = plan` validates Terraform's graph, expressions, resource arguments, dependencies, and custom assertions without provisioning Azure. This is the fast, credential-free unit-test layer.

It does not prove that Azure enforces a policy or that network traffic is blocked at runtime. Those behaviors require a separate authenticated integration suite using an isolated Azure subscription.

## Adding a module test

1. Create `tests/unit/<module>/<module>.tftest.hcl`.
2. Add `mock_provider "azurerm" {}` and any deterministic mock data or resource defaults needed by the module.
3. Add a `run` block with `module { source = "../../../modules/<module>" }`.
4. Set required module inputs in the run's `variables` block.
5. Assert the resource arguments or outputs that define the behavior being protected.
6. Run the fixture locally and then run `make test`.

## Real Azure integration suite

The real Azure suite is implemented in `.github/workflows/terraform-integration.yml` and is deliberately separate from the PR test job. It is manually dispatched, restricted to the `integration` choice, and protected by the GitHub Environment `azure-integration`, where an approval can be required.

The workflow:

- authenticates with GitHub OIDC and short-lived Azure credentials;
- applies the existing `environments/test` composition with a unique project/environment suffix;
- uses an isolated Terraform state key under `integration/<run-id>/`;
- verifies the deployed resource group, VNet, and AKS security properties with Terratest and Azure CLI;
- always attempts a resource-group cleanup, including after a failed test.

It must run only against a dedicated integration subscription and must never be changed to target `prod`. The workflow requires the GitHub Environment secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`. The Azure federated identity must be limited to this repository and the integration workflow, with permissions restricted to the dedicated test subscription/resource group.
