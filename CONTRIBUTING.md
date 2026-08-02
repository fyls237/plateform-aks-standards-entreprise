# Contributing Guide

First off, thank you for taking the time to contribute to this project! This document establishes the guidelines for contributing to the **plateform-aks-standards-entreprise** repository.

These guidelines are designed to facilitate the contribution process, ensure Terraform code quality, and maintain a robust and secure infrastructure as code (IaC).

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Process](#development-process)
3. [Branching Strategy](#branching-strategy)
4. [Coding Standards (Terraform)](#coding-standards-terraform)
5. [Commit Conventions](#commit-conventions)
6. [Pull Request (PR) Process](#pull-request-process)
7. [Security and Compliance](#security-and-compliance)

---

## Prerequisites

To contribute to this project, you must have the following tools installed on your local machine:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (respect the minimum version defined in the `versions.tf` files)
- [Azure CLI (az)](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Git](https://git-scm.com/downloads)
- [Make](https://www.gnu.org/software/make/) (used for orchestrating validation scripts)
- [pre-commit](https://pre-commit.com/) (for running local hooks)
- [terraform-docs](https://terraform-docs.io/) (for automatic documentation generation)
- [tflint](https://github.com/terraform-linters/tflint) (for static analysis)
- [tfsec](https://github.com/aquasecurity/tfsec) or [Trivy](https://trivy.dev/) (for code security)

### Local Environment Initialization

1. Clone the repository:
   ```bash
   git clone <REPO_URL>
   cd plateform-aks-standards-entreprise
   ```

2. Install pre-commit hooks (highly recommended):
   ```bash
   pre-commit install
   ```
   This ensures your code is formatted and checked before every commit.

---

## Development Process

Before submitting any changes, make sure your code passes the local validations.

You can use the `Makefile` or scripts in the `scripts/` directory to validate your code. For example:
```bash
# Check formatting and validate modules (e.g., ./scripts/validate-all.sh)
./scripts/validate-all.sh
```

---

## Branching Strategy

We follow a **GitHub Flow** / **Trunk-Based Development** approach adapted for infrastructure:

- `main` (or `master`): Main branch. It should always be in a deployable and stable state. The code on this branch represents the infrastructure in production.
- **Feature / Fix branches**: Create a branch from `main` for your developments.
  - Naming convention: `<type>/<issue-id-or-short-description>`
  - Types: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`
  - Example: `feat/add-aks-private-cluster` or `fix/update-node-pool-tags`

---

## Coding Standards (Terraform)

- **Formatting**: The code must always be formatted using `terraform fmt`.
- **Validation**: The code must pass `terraform validate`.
- **Variables**: All variables must have a `description` and, if possible, a strict `type` and `validation` blocks.
- **Outputs**: Outputs must be clearly documented.
- **Documentation**: Use `terraform-docs` to keep module `README.md` files up-to-date. The pre-commit hooks will handle this automatically if configured.
- **Paths and Names**: Prefer snake_case for Terraform resource names, variable names, and file names (e.g., `resource_group_name`).

---

## Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to automatically generate the CHANGELOG and manage semantic versioning (SemVer).

**Commit format:**
```
<type>[optional scope]: <short description>

[optional body]

[optional footer]
```

**Allowed types:**
- `feat`: Addition of a new feature (e.g., new Terraform module).
- `fix`: Bug fix (e.g., IAM policy correction).
- `docs`: Documentation changes only.
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc.).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `test`: Adding or modifying tests.
- `chore`: Updating build tasks, package manager configs, etc.

**Example:**
`feat(aks): add support for Azure CNI Overlay`

---

## Pull Request Process

1. Push your branch to the remote repository.
2. Open a Pull Request (PR) targeting the `main` branch.
3. **PR Title**: Must follow the commit conventions (e.g., `feat: add integration with Azure Key Vault`).
4. **Description**: Fill out the PR template (if one exists). Clearly describe the problem solved and the solution provided.
5. **CI/CD**: Ensure all GitHub Actions (or Azure DevOps) pipelines pass successfully (tfsec, tflint, formatting, Terraform plan).
6. **Code Review**: At least one approval (Approve) from a maintainer or another platform engineer is required before merging.
7. **Merge**: Prefer `Squash and Merge` to maintain a clean Git history on the `main` branch.

---

## Security and Compliance

Infrastructure code must adhere to enterprise security standards:

- **No plain-text secrets**: Never commit passwords, tokens, or keys in the code. Use Azure Key Vault and Data Sources references.
- **Least Privilege**: Role-based access control (RBAC) assignments must be strict and limit access to the absolute minimum necessary.
- **Private Resources**: Whenever possible, avoid exposing resources on public IP addresses without justification.
- **Static Analysis**: The code is scanned with `tfsec` and/or `checkov`. Blocking alerts in CI must be resolved before the PR can be merged.

Thank you again for your contribution to improving the platform!
