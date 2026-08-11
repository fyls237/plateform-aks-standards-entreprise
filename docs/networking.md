# Networking Architecture

## Virtual Network Design

The platform deploys a single Virtual Network per environment with dedicated subnets for isolation:

```
┌─────────────────────────────────────────────┐
│ Virtual Network (e.g., 10.100.0.0/16)       │
│                                             │
│  ┌──────────────────────────┐               │
│  │ snet-aks-nodes /20       │  4,094 IPs    │
│  │ AKS node pool VMs        │               │
│  └──────────────────────────┘               │
│                                             │
│  ┌──────────────────────────┐               │
│  │ snet-private-endpoints   │  254 IPs      │
│  │ /24                      │               │
│  └──────────────────────────┘               │
│                                             │
│  ┌──────────────────────────┐               │
│  │ snet-appgw /24 (prod)    │  254 IPs      │
│  └──────────────────────────┘               │
└─────────────────────────────────────────────┘
```

## IP Address Allocation Strategy

| Environment | VNet CIDR | AKS Nodes | Private Endpoints |
|-------------|-----------|-----------|-------------------|
| dev         | 10.100.0.0/16 | 10.100.0.0/20 | 10.100.16.0/24 |
| test        | 10.101.0.0/16 | 10.101.0.0/20 | 10.101.16.0/24 |
| preprod     | 10.102.0.0/16 | 10.102.0.0/20 | 10.102.16.0/24 |
| prod        | 10.103.0.0/16 | 10.103.0.0/20 | 10.103.16.0/24 |

Non-overlapping CIDRs allow VNet peering between environments if needed.

## Azure CNI Overlay

The platform uses **Azure CNI Overlay** for pod networking:

- **Benefit**: Pod IPs are drawn from a separate overlay address space (`10.244.0.0/16`), not from the VNet
- **Result**: You only need to size subnets for *nodes*, not for pods
- **Max pods per node**: 110 (configurable)

### Why Not Azure CNI (Traditional)?

Traditional Azure CNI pre-allocates pod IPs from the VNet subnet, which leads to:
- Subnet exhaustion at scale (250 nodes × 110 pods = 27,500 IPs)
- Wasteful IP reservation
- Complex CIDR planning

CNI Overlay avoids all of these issues.

## Network Security Groups

### Strategy

- **Default deny** all inbound traffic in preprod/prod
- **Explicit allow** only required traffic
- **Service tags** used where possible (e.g., `AzureLoadBalancer`, `VirtualNetwork`)

### Default Rules (Production)

| Priority | Name | Direction | Action | Source | Destination | Port |
|----------|------|-----------|--------|--------|-------------|------|
| 100 | AllowHTTPSFromVnet | Inbound | Allow | VirtualNetwork | VirtualNetwork | 443 |
| 110 | AllowAzureLB | Inbound | Allow | AzureLoadBalancer | * | * |
| 4096 | DenyAllInbound | Inbound | Deny | * | * | * |

## Route Tables

Route tables are optional and can be used for:

- **User-Defined Routes (UDR)** to force traffic through a firewall (Azure Firewall, NVA)
- **BGP route propagation** control for ExpressRoute/VPN scenarios

## Private Endpoints

In production environments, all PaaS services are accessed via private endpoints:

| Service | Private DNS Zone | Subnet |
|---------|-----------------|--------|
| ACR | privatelink.azurecr.io | snet-private-endpoints |
| Key Vault | privatelink.vaultcore.azure.net | snet-private-endpoints |
| AKS API Server | privatelink.<region>.azmk8s.io | snet-aks-nodes |

### DNS Resolution

Private DNS zones are linked to the VNet, ensuring that:
1. `myacr.azurecr.io` resolves to a private IP within the VNet
2. The AKS API server (`*.privatelink.<region>.azmk8s.io`) resolves natively for nodes and VNet clients
3. No traffic leaves the Azure backbone
4. NSG rules on the subnets control access

## Hub-and-Spoke Readiness

The VNet design is compatible with Azure hub-and-spoke topologies:

- **Non-overlapping CIDRs** across environments
- **Route tables** support UDR to a hub firewall
- **DNS forwarding** can be configured via the networking module's `dns_servers` variable
- **VNet peering** can be added by extending the networking module

## DDoS Protection & Diagnostics

For internet-facing, production workloads (e.g., exposing an Application Gateway), the networking module supports:
- **DDoS Protection Plan**: A native Azure DDoS plan can be attached to the Virtual Network to mitigate volumetric attacks.
- **VNet Diagnostics**: Native Virtual Network metrics and `VMProtectionAlerts` are exported to Log Analytics for centralized observability.
