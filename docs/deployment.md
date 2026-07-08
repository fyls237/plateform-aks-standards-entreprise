# Deployment Guide

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.12
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) >= 2.70
- Azure subscription with `Owner` or `Contributor` + `User Access Administrator` roles
- Azure AD group for AKS cluster admin (recommended)

## Quick Start

### 1. Authenticate to Azure

```bash
az login
az account set --subscription "<subscription-id>"
```

### 2. Create Remote State Backend

```bash
chmod +x scripts/setup-backend.sh
./scripts/setup-backend.sh
```

This creates:
- Resource group: `rg-terraform-state`
- Storage account: `stterraformstate<random>`
- Container: `tfstate`

### 3. Configure Variables

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Initialize and Deploy

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Or using the Makefile:

```bash
make ENVIRONMENT=dev init
make ENVIRONMENT=dev plan
make ENVIRONMENT=dev apply
```

### 5. Get AKS Credentials

```bash
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw aks_cluster_name)
```

## Environment Deployment Order

For a new platform, deploy environments in order:

1. **dev** — validate configuration, iterate on changes
2. **test** — run integration tests
3. **preprod** — validate production-like setup
4. **prod** — production deployment

## Backend Configuration

Each environment has its own state file in Azure Storage:

| Environment | State Key |
|-------------|-----------|
| dev | `dev/platform-aks.tfstate` |
| test | `test/platform-aks.tfstate` |
| preprod | `preprod/platform-aks.tfstate` |
| prod | `prod/platform-aks.tfstate` |

Update `backend.tf` in each environment with your storage account name.

### Using Partial Configuration

For CI/CD, use partial backend configuration:

```bash
terraform init \
  -backend-config="resource_group_name=rg-terraform-state" \
  -backend-config="storage_account_name=stterraformstate123" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev/platform-aks.tfstate"
```

## CI/CD Integration

### GitHub Actions

The repository includes workflows for:

1. **terraform-ci.yml** — Runs on PRs: format check, validate, lint, security scan
2. **terraform-plan.yml** — Runs on PRs to main: generates plan per environment
3. **terraform-apply.yml** — Manual dispatch: applies changes with approval

### Required Secrets

Configure these in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Service Principal or Managed Identity client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |

### OIDC Authentication (Recommended)

Use GitHub OIDC federation instead of client secrets:

```bash
# Create federated credential for GitHub Actions
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<org>/<repo>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Destroying Infrastructure

```bash
# Always plan destroy first
terraform plan -destroy -out=tfplan

# Review the plan, then apply
terraform apply tfplan
```

> **Warning**: Production environments have resource locks. Remove locks before destroy:
> ```bash
> az lock delete --name rg-lock --resource-group <rg-name>
> ```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `Error: Backend configuration changed` | Run `terraform init -reconfigure` |
| `Error: Provider not found` | Run `terraform init -upgrade` |
| `Error: Resource group is locked` | Remove management lock before modifications |
| `Timeout creating AKS cluster` | AKS creation can take 10-15 minutes; increase timeout |
| `ACR pull fails` | Verify `AcrPull` role assignment exists for kubelet identity |
