# Roadmap

## Current State (v0.1.0)

✅ AKS cluster with Azure CNI Overlay  
✅ Managed Identity + Workload Identity  
✅ Azure RBAC for Kubernetes  
✅ Private cluster support  
✅ Multi-environment (dev/test/preprod/prod)  
✅ Azure Container Registry (Premium)  
✅ Key Vault with RBAC  
✅ Log Analytics + Container Insights  
✅ Metric alerts  
✅ Private endpoints  
✅ NSGs and route tables  
✅ Private DNS zones  
✅ GitHub Actions CI/CD  

## Short-term (v0.2.0)

### GitOps

- [ ] **FluxCD** — Bootstrap FluxCD on AKS clusters for GitOps-based deployments
- [ ] **ArgoCD** — Alternative GitOps engine with UI

### Policy & Compliance

- [ ] **Azure Policy** — Built-in and custom policies for AKS
- [ ] **Gatekeeper/OPA** — Kubernetes-native admission control
- [ ] **Defender for Cloud** — Enable Defender for Containers

### Networking

- [ ] **Application Gateway Ingress Controller (AGIC)** — L7 load balancing
- [ ] **Azure Firewall** — Egress filtering and FQDN rules
- [ ] **VNet peering** — Hub-and-spoke connectivity

## Medium-term (v0.3.0)

### Observability

- [ ] **Prometheus** — Managed Prometheus (Azure Monitor workspace)
- [ ] **Grafana** — Managed Grafana dashboards
- [ ] **Distributed tracing** — OpenTelemetry integration

### DNS & Certificates

- [ ] **ExternalDNS** — Automatic DNS record management
- [ ] **cert-manager** — Automated TLS certificate provisioning
- [ ] **Azure DNS integration** — Public and private zone management

### Backup & DR

- [ ] **Velero** — Kubernetes backup and disaster recovery
- [ ] **Azure Backup for AKS** — Native backup solution

## Long-term (v1.0.0)

### Multi-region

- [ ] **Multi-region AKS** — Active-active or active-passive clusters
- [ ] **Azure Front Door** — Global load balancing
- [ ] **Geo-replicated ACR** — Cross-region image availability
- [ ] **Cosmos DB** — Multi-region data layer

### Advanced Deployment

- [ ] **Blue/Green deployments** — Cluster-level or namespace-level
- [ ] **Canary deployments** — Progressive delivery with Flagger
- [ ] **Service Mesh** — Istio or Linkerd for mTLS, traffic splitting

### Platform Engineering

- [ ] **Terragrunt** — DRY configuration management
- [ ] **Backstage** — Internal Developer Portal
- [ ] **Crossplane** — Kubernetes-native infrastructure management
- [ ] **Score** — Workload specification

### Governance

- [ ] **Azure Landing Zones** — Full CAF integration
- [ ] **Management groups** — Multi-subscription hierarchy
- [ ] **Cost management** — Budgets, alerts, tagging enforcement
- [ ] **FinOps** — Cost optimization recommendations

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) (planned) for contribution guidelines.

Roadmap items are tracked as GitHub Issues with the `roadmap` label.
