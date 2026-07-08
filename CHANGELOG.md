# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/fyls237/plateform-aks-standards-entreprise/compare/v0.1.0...v0.2.0) (2026-07-08)


### Features

* **infra:** update modules name and remove tf lock ([8a6b01b](https://github.com/fyls237/plateform-aks-standards-entreprise/commit/8a6b01be6c4ae8bf6cec202e8650f7478e5d24e7))
* **infra:** update modules name and remove tf lock ([5d8e43b](https://github.com/fyls237/plateform-aks-standards-entreprise/commit/5d8e43b83192b8c62c65d9977ec50766e89577bc))

## 0.1.0 (2026-07-08)


### Features

* **ci:** add release please dependabot ([41b9b16](https://github.com/fyls237/plateform-aks-standards-entreprise/commit/41b9b16b3e3338964cbf6e2552a24eb382410e4e))
* first setup infra modules ([e460e75](https://github.com/fyls237/plateform-aks-standards-entreprise/commit/e460e7536b3734a0c5301e30ea47f85944bb9bd1))

## [Unreleased]

## [0.1.0] - 2026-07-07

### Added

- Initial platform release
- **Networking module** — Virtual Network, Subnets, NSGs, Route Tables, Diagnostic Settings
- **AKS module** — Azure Kubernetes Service with CNI Overlay, Workload Identity, Azure RBAC, Private Cluster support, Autoscaler
- **ACR module** — Azure Container Registry (Premium), geo-replication, private endpoint support
- **Key Vault module** — Azure Key Vault with RBAC authorization, soft delete, purge protection
- **Monitor module** — Azure Monitor workspace, alert rules, action groups
- **Identities module** — User-assigned Managed Identities, Federated Identity Credentials
- **Log Analytics module** — Log Analytics workspace, Container Insights solution
- **Private DNS module** — Private DNS zones, VNet links
- **Environments** — dev, test, preprod, prod configurations
- **Examples** — simple, enterprise, private-cluster deployment patterns
- **CI/CD** — GitHub Actions workflows for fmt, validate, lint, security scan, plan
- **Documentation** — Architecture, networking, security, deployment, decisions, roadmap

[Unreleased]: https://github.com/your-org/platform-aks-standards-enterprise/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/your-org/platform-aks-standards-enterprise/releases/tag/v0.1.0
