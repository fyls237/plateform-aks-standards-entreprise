# 🏗️ Enterprise AKS Platform Starter

[![Terraform CI](https://github.com/your-org/platform-aks-standards-enterprise/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/your-org/platform-aks-standards-enterprise/actions/workflows/terraform-ci.yml)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.12-7B42BC?logo=terraform)](https://www.terraform.io)
[![Azure](https://img.shields.io/badge/Azure-AKS-0078D4?logo=microsoftazure)](https://azure.microsoft.com/services/kubernetes-service/)

> A **production-grade, enterprise-ready** Azure Kubernetes Service (AKS) platform foundation built with Terraform. Designed by platform engineers, for platform engineers.

This is not a tutorial repository. It is a reusable, modular, and maintainable platform starter that mirrors what a Cloud Platform Team would operate inside a large enterprise.

---

## 📋 Table of Contents

- [Architecture](#-architecture)
- [Features](#-features)
- [Repository Structure](#-repository-structure)
- [Quick Start](#-quick-start)
- [Modules](#-modules)
- [Environments](#-environments)
- [Examples](#-examples)
- [Configuration](#-configuration)
- [CI/CD](#-cicd)
- [Security](#-security)
- [Cost Optimization](#-cost-optimization)
- [Use Cases](#-use-cases)
- [Architecture Decisions](#-architecture-decisions)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🏛️ Architecture

```mermaid
graph TB
    subgraph "Azure Subscription"
        subgraph "Resource Group"
            subgraph "Networking"
                VNET["🌐 Virtual Network"]
                SNET_AKS["Subnet: AKS Nodes"]
                SNET_PE["Subnet: Private Endpoints"]
                NSG["Network Security Groups"]
            end

            subgraph "Compute"
                AKS["☸️ AKS Cluster"]
                SYS["System Pool"]
                WORK["Workload Pool"]
                MEM["Memory Pool"]
            end

            subgraph "Security"
                MI["🔐 Managed Identities"]
                KV["🔑 Key Vault"]
                WI["Workload Identity"]
            end

            subgraph "Registry"
                ACR["📦 Container Registry"]
            end

            subgraph "Observability"
                LAW["📊 Log Analytics"]
                MON["🔔 Alerts"]
            end

            subgraph "DNS"
                DNS["🌍 Private DNS Zones"]
            end
        end
    end

    VNET --> SNET_AKS --> AKS
    VNET --> SNET_PE
    NSG --> SNET_AKS
    MI --> AKS
    WI --> MI
    AKS --> SYS & WORK & MEM
    ACR -.->|Private Endpoint| SNET_PE
    KV -.->|Private Endpoint| SNET_PE
    AKS -.->|Container Insights| LAW
    LAW --> MON
    DNS --> VNET

    style AKS fill:#326CE5,stroke:#fff,color:#fff
    style ACR fill:#0078D4,stroke:#fff,color:#fff
    style KV fill:#0078D4,stroke:#fff,color:#fff
    style LAW fill:#0078D4,stroke:#fff,color:#fff
    style VNET fill:#00BCF2,stroke:#fff,color:#fff
```

### Component Overview

| Component | Purpose | Azure Service |
|-----------|---------|---------------|
| **Networking** | Network isolation, segmentation, security | VNet, NSG, UDR, Private Endpoints |
| **AKS Cluster** | Container orchestration with enterprise features | Azure Kubernetes Service |
| **Container Registry** | Secure image storage and distribution | Azure Container Registry (Premium) |
| **Key Vault** | Secrets, keys, and certificates management | Azure Key Vault |
| **Identities** | Zero-trust identity for cluster and workloads | Managed Identity, Workload Identity |
| **Log Analytics** | Centralized logging and Container Insights | Log Analytics Workspace |
| **Monitoring** | Alerting and diagnostic data collection | Azure Monitor |
| **Private DNS** | Private name resolution for PaaS services | Private DNS Zones |

### How Modules Interact

1. **Networking** creates the VNet foundation — all other modules depend on subnet IDs
2. **Identities** provisions managed identities — AKS and ACR reference these
3. **Log Analytics** provides the workspace — AKS, ACR, Key Vault, and NSGs send diagnostics here
4. **Private DNS** creates zones — ACR and Key Vault private endpoints register here
5. **AKS** consumes networking, identity, and monitoring — the central module
6. **Monitor** attaches to AKS — collects diagnostics and fires alerts

---

## ✨ Features

### Kubernetes & Compute
- ☸️ AKS with **Azure CNI Overlay** networking
- 🔄 Cluster **autoscaler** with configurable min/max
- 📦 Multiple **node pools** (system, workload, memory-optimized, spot)
- 🐧 **AzureLinux** node OS (optimized for containers)
- ⬆️ **Automatic upgrades** with configurable channels
- 🧹 **Image cleaner** for unused container images
- 🛠️ **Maintenance windows** for controlled upgrades

### Security & Identity
- 🔐 **User-Assigned Managed Identity** (lifecycle-independent)
- 🎫 **Workload Identity** with OIDC federation
- 🛡️ **Azure RBAC** for Kubernetes authorization
- 🚫 **Local account disabled** (enforces Azure AD)
- 🔑 **Key Vault** with RBAC authorization
- 🔒 **Private cluster** option (no public API server)
- 🌐 **Private endpoints** for all PaaS services

### Networking
- 🏗️ **Virtual Network** with dedicated subnets
- 🛡️ **NSGs** with deny-all default in production
- 🗺️ **Route tables** for UDR/firewall scenarios
- 🌍 **Private DNS zones** for service name resolution
- 🔌 **Hub-and-spoke ready** architecture

### Observability
- 📊 **Log Analytics** with Container Insights
- 🔔 **Metric alerts** (CPU, memory, pod restarts)
- 📋 **Diagnostic settings** on all resources
- 📧 **Action groups** for alert notifications

### Operations
- 🏷️ **Consistent tagging** strategy
- 📛 **Naming convention** with environment and region
- 🔒 **Resource locks** in production
- 💰 **Cost-optimized** per-environment sizing
- 📄 **Remote state** in Azure Storage

---

## 📁 Repository Structure

```
.
├── modules/                    # Reusable Terraform modules
│   ├── aks/                    # AKS cluster with node pools
│   ├── networking/             # VNet, Subnets, NSGs, Route Tables
│   ├── acr/                    # Azure Container Registry
│   ├── keyvault/               # Azure Key Vault
│   ├── monitor/                # Diagnostic settings & alerts
│   ├── identities/             # Managed identities & RBAC
│   ├── log-analytics/          # Log Analytics workspace
│   └── private-dns/            # Private DNS zones & VNet links
│
├── environments/               # Per-environment deployments
│   ├── dev/                    # Development (cost-optimized)
│   ├── test/                   # Testing (medium sizing)
│   ├── preprod/                # Pre-production (prod-like)
│   └── prod/                   # Production (fully hardened)
│
├── examples/                   # Standalone deployment examples
│   ├── simple/                 # Minimal AKS + VNet + ACR
│   ├── enterprise/             # Full-featured with all modules
│   └── private-cluster/        # Private AKS + private endpoints
│
├── docs/                       # Technical documentation
│   ├── architecture.md         # Platform architecture & diagrams
│   ├── networking.md           # Networking deep dive
│   ├── security.md             # Security model
│   ├── deployment.md           # Deployment guide
│   ├── decisions.md            # Architecture Decision Records
│   └── roadmap.md              # Future improvements
│
├── scripts/                    # Automation scripts
│   ├── setup-backend.sh        # Create Terraform state backend
│   └── validate-all.sh         # Validate all configurations
│
├── .github/workflows/          # CI/CD pipelines
│   ├── terraform-ci.yml        # Format, validate, lint, security
│   ├── terraform-plan.yml      # Plan per environment on PR
│   └── terraform-apply.yml     # Manual apply with approval
│
├── Makefile                    # Developer shortcuts
├── CHANGELOG.md                # Version history
└── LICENSE                     # MIT License
```

---

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.12
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) >= 2.70
- Azure subscription with appropriate permissions

### 1. Clone & Configure

```bash
git clone https://github.com/your-org/platform-aks-standards-enterprise.git
cd platform-aks-standards-enterprise

# Create state backend
./scripts/setup-backend.sh

# Configure environment
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
```

### 2. Deploy

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Connect

```bash
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw aks_cluster_name)

kubectl get nodes
```

> See [docs/deployment.md](docs/deployment.md) for the full deployment guide.

---

## 📦 Modules

### `modules/networking`
Virtual Network with configurable subnets, NSGs with dynamic security rules, route tables for UDR scenarios, and diagnostic settings.

### `modules/aks`
AKS cluster with Azure CNI Overlay, user-assigned managed identity, Workload Identity, Azure RBAC, private cluster option, autoscaler, maintenance windows, and multiple node pool support.

### `modules/acr`
Azure Container Registry (Premium) with geo-replication, private endpoint, retention policies, network rule sets, AcrPull role assignment, and diagnostic settings.

### `modules/keyvault`
Azure Key Vault with RBAC authorization, soft delete, purge protection, network ACLs, private endpoint, and audit logging.

### `modules/monitor`
Azure Monitor diagnostic settings for AKS, metric alert rules with smart defaults (CPU, memory, pod restarts), and action groups.

### `modules/identities`
User-assigned managed identities, Azure RBAC role assignments, and federated identity credentials for Workload Identity.

### `modules/log-analytics`
Log Analytics workspace with configurable retention and ContainerInsights solution.

### `modules/private-dns`
Private DNS zones with VNet links for PaaS service resolution.

---

## 🌍 Environments

| Environment | Private Cluster | Node VM | System Pool | Workload Pool | SKU Tier | Alerts | Locks |
|-------------|:-:|---------|:-:|:-:|----------|:-:|:-:|
| **dev** | ❌ | D2s_v5 | 1-3 | 1-5 | Free | ❌ | ❌ |
| **test** | ❌ | D2s-D4s_v5 | 2-4 | 2-8 | Standard | ✅ | ❌ |
| **preprod** | ✅ | D4s_v5 | 2-5 | 3-15 | Standard | ✅ | ❌ |
| **prod** | ✅ | D4s_v5 | 3-6 | 3-20 + memory pool | Standard | ✅ | ✅ |

---

## 📖 Examples

### Simple
Minimal deployment for quick evaluation. VNet + AKS + ACR, no private endpoints.

```bash
cd examples/simple
terraform init && terraform apply
```

### Enterprise
Full-featured deployment with all modules, private endpoints for ACR and Key Vault, monitoring with alerts.

```bash
cd examples/enterprise
terraform init && terraform apply
```

### Private Cluster
AKS with private API server, private endpoints for all PaaS services, no public network access.

```bash
cd examples/private-cluster
terraform init && terraform apply
```

---

## ⚙️ Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region | `westeurope` |
| `project` | Project name for naming convention | `aksplatform` |
| `environment` | Environment name | `dev` |
| `admin_group_object_ids` | Azure AD groups for cluster admin | `[]` |
| `alert_email_receivers` | Email addresses for alerts | `[]` |

See each environment's `variables.tf` for the full variable reference.

### Naming Convention

Resources follow: `{type}-{project}-{environment}-{region}`

Examples:
- `rg-aksplatform-dev-weu`
- `aks-aksplatform-prod-weu`
- `vnet-aksplatform-preprod-weu`

---

## 🔄 CI/CD

### Workflows

| Workflow | Trigger | Actions |
|----------|---------|---------|
| **terraform-ci** | PR to main | Format, Validate, TFLint, Checkov |
| **terraform-plan** | PR to main | `terraform plan` per environment |
| **terraform-apply** | Manual dispatch | `terraform apply` with environment selector |

### Required Secrets

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App registration or managed identity client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |
| `BACKEND_RESOURCE_GROUP` | State backend resource group |
| `BACKEND_STORAGE_ACCOUNT` | State backend storage account |

---

## 🔒 Security

### Defense in Depth

| Layer | Control |
|-------|---------|
| **Identity** | Azure AD + Managed Identity + Workload Identity |
| **Authorization** | Azure RBAC (unified for Azure + Kubernetes) |
| **Network** | Private cluster + NSG deny-all + Private endpoints |
| **Secrets** | Key Vault with RBAC + Purge protection |
| **Audit** | Log Analytics + Diagnostic settings on all resources |
| **Encryption** | TLS in transit, Azure-managed encryption at rest |

> See [docs/security.md](docs/security.md) for the complete security architecture.

---

## 💰 Cost Optimization

### Recommendations by Environment

| Strategy | Dev | Test | Preprod | Prod |
|----------|:---:|:----:|:-------:|:----:|
| Free AKS tier | ✅ | ❌ | ❌ | ❌ |
| Smaller VMs | ✅ | ✅ | ❌ | ❌ |
| Fewer nodes | ✅ | ✅ | ❌ | ❌ |
| Spot instances | ✅ | ✅ | ❌ | ❌ |
| Disable alerts | ✅ | ❌ | ❌ | ❌ |
| Shorter log retention | ✅ | ✅ | ❌ | ❌ |
| Zone redundancy | ❌ | ❌ | ❌ | ✅ |

### General Tips

- Use **autoscaler** to scale down during low usage
- Use **Spot node pools** for fault-tolerant workloads
- Set **log retention** based on compliance requirements
- Use **Azure Reservations** for production VMs
- Review **Azure Advisor** recommendations regularly

---

## 🎯 Use Cases

### Enterprise Landing Zone
Deploy as part of an Azure Landing Zone, providing the application platform layer within a hub-and-spoke network.

### Internal Developer Platform
Foundation for an IDP where development teams self-service Kubernetes namespaces with guardrails.

### Customer Kubernetes Platform
Reusable template for consulting engagements delivering managed Kubernetes to clients.

### Multi-Environment Deployment
4-environment pipeline (dev → test → preprod → prod) with progressive security hardening.

### CI/CD Platform
Host build agents, artifact caches, and deployment tooling on dedicated node pools.

### AI/ML Platform
Leverage memory-optimized and GPU node pools (roadmap) for training and inference workloads.

### Microservices Platform
Run microservices with Workload Identity for per-service Azure access, network policies for isolation.

### SaaS Platform
Multi-tenant SaaS with namespace isolation, per-tenant resource quotas, and centralized observability.

### Regulated Environments
Financial services, healthcare — private cluster, audit logging, NSG rules, Key Vault for secrets.

---

## 🏗️ Architecture Decisions

Key decisions documented as ADRs in [docs/decisions.md](docs/decisions.md):

| ADR | Decision | Rationale |
|-----|----------|-----------|
| 001 | Azure CNI Overlay | Avoids IP exhaustion, simplifies subnet sizing |
| 002 | User-Assigned Identity | Lifecycle-independent, pre-provisioned RBAC |
| 003 | Azure RBAC for K8s | Unified identity plane, Conditional Access |
| 004 | Premium ACR | Required for private endpoints, geo-replication |
| 005 | Key Vault RBAC | Granular, auditable, Azure-recommended |
| 006 | AzureLinux Node OS | Smaller attack surface, optimized for containers |
| 007 | Local Module Sources | Atomic changes, easy to evolve |

---

## 🗺️ Roadmap

See [docs/roadmap.md](docs/roadmap.md) for the full roadmap.

**Short-term**: FluxCD/ArgoCD, Azure Policy, Defender for Cloud  
**Medium-term**: Prometheus/Grafana, cert-manager, ExternalDNS, Velero  
**Long-term**: Multi-region, Service Mesh, Backstage, Crossplane

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ by the Platform Engineering Team**

[Architecture](docs/architecture.md) · [Security](docs/security.md) · [Deployment](docs/deployment.md) · [Roadmap](docs/roadmap.md)

</div>