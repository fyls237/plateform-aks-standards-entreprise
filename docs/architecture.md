# Platform Architecture

## Overview

The AKS Platform Starter provides a modular, enterprise-grade foundation for deploying Azure Kubernetes Service clusters with all supporting infrastructure.

## Architecture Diagram

```mermaid
graph TB
    subgraph "Azure Subscription"
        subgraph "Resource Group"
            subgraph "Edge Security"
                APPGW["🛡️ Application Gateway (WAF)"]
                PIP["Public IP"]
            end

            subgraph "Networking"
                VNET["Virtual Network"]
                SNET_AKS["Subnet: AKS Nodes"]
                SNET_PE["Subnet: Private Endpoints"]
                SNET_AGW["Subnet: AppGW"]
                NSG_AKS["NSG: AKS"]
                NSG_PE["NSG: Private Endpoints"]
                RT["Route Table"]
            end

            subgraph "Identity"
                MI_AKS["Managed Identity: AKS"]
                MI_KUBELET["Managed Identity: Kubelet"]
                FIC["Federated Identity Credentials"]
            end

            subgraph "AKS Cluster"
                AKS["AKS Control Plane"]
                NP_SYS["Node Pool: System"]
                NP_WORK["Node Pool: Workload"]
                NP_MEM["Node Pool: Memory"]
            end

            subgraph "Container Registry"
                ACR["Azure Container Registry"]
                ACR_PE["Private Endpoint"]
            end

            subgraph "Secrets Management"
                KV["Azure Key Vault"]
                KV_PE["Private Endpoint"]
            end

            subgraph "Observability"
                LAW["Log Analytics Workspace"]
                CI["Container Insights"]
                DIAG["Diagnostic Settings"]
                ALERTS["Metric Alerts"]
                AG["Action Group"]
            end

            subgraph "DNS"
                DNS_ACR["Private DNS: ACR"]
                DNS_KV["Private DNS: Key Vault"]
                DNS_AKS["Private DNS: AKS"]
            end
        end
    end

    PIP --> APPGW
    APPGW --> SNET_AGW
    SNET_AGW --> AKS

    VNET --> SNET_AKS
    VNET --> SNET_PE
    VNET --> SNET_AGW
    SNET_AKS --> NSG_AKS
    SNET_PE --> NSG_PE
    SNET_AKS --> RT

    MI_AKS --> AKS
    MI_KUBELET --> AKS
    FIC --> MI_KUBELET

    AKS --> NP_SYS
    AKS --> NP_WORK
    AKS --> NP_MEM
    AKS --> SNET_AKS

    ACR --> ACR_PE --> SNET_PE
    KV --> KV_PE --> SNET_PE

    MI_KUBELET -.->|AcrPull| ACR
    AKS -.->|Diagnostics| LAW
    LAW --> CI
    LAW --> DIAG
    ALERTS --> AG
    ALERTS -.-> AKS

    DNS_ACR --> VNET
    DNS_KV --> VNET
    DNS_AKS --> VNET
    ACR_PE -.-> DNS_ACR
    KV_PE -.-> DNS_KV
    AKS -.-> DNS_AKS

    style AKS fill:#326CE5,stroke:#fff,color:#fff
    style ACR fill:#0078D4,stroke:#fff,color:#fff
    style KV fill:#0078D4,stroke:#fff,color:#fff
    style LAW fill:#0078D4,stroke:#fff,color:#fff
    style VNET fill:#00BCF2,stroke:#fff,color:#fff
    style APPGW fill:#F39C12,stroke:#fff,color:#fff
```

## Component Interaction

### Data Flow

1. **Control Plane Identity** → AKS & VNet: User-assigned managed identity is attached to the AKS cluster at creation. It holds `Network Contributor` on the subnet to manage Load Balancers and `Managed Identity Operator` on the Kubelet identity.
2. **Kubelet Identity** → ACR: A separate, dedicated kubelet identity is granted `AcrPull` to pull container images.
3. **AKS** → VNet: Nodes are deployed into a dedicated subnet with NSG and route table
4. **AKS** → Log Analytics: Container Insights agent forwards logs and metrics
5. **Private DNS** → VNet: Private DNS zones resolve service FQDNs to private IPs (AKS API Server, ACR, Key Vault)
6. **Monitor** → AKS: Diagnostic settings capture control plane logs; metric alerts fire on threshold
7. **Edge Security** → AKS: Application Gateway inspects incoming traffic using WAF and routes it to the AKS Ingress Controller (via AGIC or NGINX ILB).

### Module Dependencies

```mermaid
graph LR
    NET["networking"] --> AKS["aks"]
    NET --> ACR["acr"]
    NET --> KV["keyvault"]
    NET --> APP["appgw"]
    LOG["log-analytics"] --> AKS
    LOG --> ACR
    LOG --> KV
    LOG --> MON["monitor"]
    LOG --> NET
    LOG --> APP
    ID["identities"] --> AKS
    DNS["private-dns"] --> ACR
    DNS --> KV
    DNS --> AKS
    NET --> DNS
    AKS --> MON
    APP <--> AKS

    style AKS fill:#326CE5,stroke:#fff,color:#fff
    style APP fill:#F39C12,stroke:#fff,color:#fff
```

## Networking Architecture

The platform uses a hub-and-spoke-ready design:

| Subnet | Purpose | Default CIDR |
|--------|---------|--------------|
| `snet-aks-nodes` | AKS node pool VMs | `/20` (4,094 IPs) |
| `snet-private-endpoints` | Private endpoints for PaaS services | `/24` (254 IPs) |
| `snet-appgw` | Application Gateway (prod only) | `/24` (254 IPs) |

### CNI Overlay

Azure CNI Overlay is used for pod networking:

- **Node IPs** come from the VNet subnet
- **Pod IPs** come from a separate overlay CIDR (`10.244.0.0/16` by default)
- This avoids IP exhaustion in the VNet and simplifies subnet sizing

## Security Model

See [security.md](security.md) for the full security architecture.

### Key Principles

1. **No public API server** in production (private cluster)
2. **No admin user** on ACR (managed identity only)
3. **RBAC authorization** for Key Vault (not access policies)
4. **Azure RBAC** for Kubernetes (unified identity plane)
5. **Workload Identity** for pod-level Azure AD authentication
6. **NSG deny-all** with explicit allow rules
7. **Private endpoints** for all PaaS services in production
