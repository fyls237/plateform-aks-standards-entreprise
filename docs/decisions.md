# Architecture Decision Records

## ADR-001: Azure CNI Overlay over Traditional CNI

**Status**: Accepted  
**Date**: 2026-07-07

### Context
AKS supports multiple CNI options: kubenet, Azure CNI, Azure CNI Overlay, Azure CNI powered by Cilium.

### Decision
Use **Azure CNI Overlay** as the default network plugin.

### Rationale
- Pod IPs come from a separate overlay space, not from the VNet subnet
- Simplifies IP address planning — subnets only need to accommodate nodes
- Supports up to 250 nodes and 110 pods per node without CIDR pressure
- Azure CNI Overlay is GA and supported for production

### Trade-offs
- Slightly higher latency compared to traditional Azure CNI (negligible in practice)
- Pod IPs are not directly routable from outside the cluster (use Services/Ingress)

---

## ADR-002: User-Assigned Managed Identity over System-Assigned

**Status**: Accepted  
**Date**: 2026-07-07

### Context
AKS supports both System-Assigned and User-Assigned Managed Identities.

### Decision
Use **User-Assigned Managed Identity** for the AKS cluster.

### Rationale
- Identity lifecycle is decoupled from the cluster — survives cluster re-creation
- RBAC role assignments can be pre-provisioned before cluster creation
- Enables consistent identity management across environments
- Aligns with enterprise identity governance patterns

### Trade-offs
- Slightly more Terraform code (identity must be created before the cluster)
- Additional resource to manage

---

## ADR-003: Azure RBAC for Kubernetes over Native K8s RBAC

**Status**: Accepted  
**Date**: 2026-07-07

### Context
AKS supports Kubernetes-native RBAC and Azure RBAC for Kubernetes authorization.

### Decision
Use **Azure RBAC for Kubernetes** as the authorization mode.

### Rationale
- Unified identity plane — same Azure AD groups for Azure and Kubernetes access
- Centralized audit trail in Azure AD sign-in logs
- Conditional Access policies (MFA, device compliance) apply automatically
- No need to manage ClusterRoleBindings via kubectl

### Trade-offs
- Requires Azure AD Premium for Conditional Access features
- Learning curve for teams used to Kubernetes-native RBAC
- Azure RBAC role assignments have a propagation delay (~5 minutes)

---

## ADR-004: Premium ACR SKU as Default

**Status**: Accepted  
**Date**: 2026-07-07

### Context
ACR supports Basic, Standard, and Premium SKUs.

### Decision
Default to **Premium SKU** for all environments.

### Rationale
- Required for private endpoints (production requirement)
- Supports geo-replication for multi-region scenarios
- Content trust (image signing) only available on Premium
- Retention policies for untagged manifests
- Network rule sets for IP-based restrictions

### Trade-offs
- Higher cost (~$1.67/day vs ~$0.17/day for Basic)
- For dev/test, could use Standard if private endpoints aren't needed

---

## ADR-005: Key Vault RBAC over Access Policies

**Status**: Accepted  
**Date**: 2026-07-07

### Context
Key Vault supports two authorization models: Access Policies and RBAC.

### Decision
Use **RBAC authorization** for Key Vault.

### Rationale
- More granular permissions (per-secret, per-key access)
- Consistent with Azure RBAC patterns used elsewhere
- Auditable via Azure AD activity logs
- Supports Conditional Access
- Azure's recommended approach for new deployments

### Trade-offs
- Access policies are still required for some legacy integrations
- RBAC role propagation can take a few minutes

---

## ADR-006: AzureLinux over Ubuntu for Node OS

**Status**: Accepted  
**Date**: 2026-07-07

### Context
AKS supports Ubuntu, AzureLinux (formerly Mariner), and Windows node OS images.

### Decision
Use **AzureLinux** as the default node OS.

### Rationale
- Purpose-built for container workloads by Microsoft
- Smaller attack surface (fewer packages installed)
- Faster boot times and smaller image size
- Optimized kernel for containerized applications
- Consistent patching via the AKS node image upgrade channel

### Trade-offs
- Less community documentation compared to Ubuntu
- Some third-party tools may not be tested on AzureLinux

---

## ADR-007: Local Module Sources over Registry Modules

**Status**: Accepted  
**Date**: 2026-07-07

### Context
Terraform modules can be sourced from local paths, git repos, or registries.

### Decision
Use **local paths** (`../../modules/xxx`) for module sources.

### Rationale
- Simplicity — single repository, no external dependencies
- Atomic changes — module and environment changes in the same PR
- No version management overhead during initial development
- Easy to convert to registry modules later by changing `source` and adding `version`

### Trade-offs
- No version pinning — all environments use the same module version
- Cannot share modules across separate repositories without publishing
- For multi-team organizations, a Terraform Registry is recommended
