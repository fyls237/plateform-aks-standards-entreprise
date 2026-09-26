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
- Strict separation of concerns: A dedicated identity for the Control Plane (Network Contributor) and a separate one for the Kubelet (AcrPull)
- The Control Plane identity is explicitly granted `Managed Identity Operator` over the Kubelet identity to attach it to VMSS nodes
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
- ~~Content trust (image signing)~~ — DCT deprecated by Microsoft (retirement March 2028), use [Notary Project](https://notaryproject.dev/) instead
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

---

## ADR-008: Commit Provider Lock Files & Controlled Version Bumps

**Status**: Accepted
**Date**: 2026-09-24

### Context
This platform is deployed as **one codebase serving multiple client
environments** (dev/test/preprod/prod, potentially forked per client until
ADR-007/the multi-tenant control plane lands). `make clean` used to delete
`.terraform.lock.hcl` unconditionally, and the file was git-ignored for the
whole repo. Combined with the open-ended provider constraint
(`azurerm ~> 4.15`, i.e. any `4.x >= 4.15`), this meant:

- Two client deployments run on different dates could silently resolve
  **different azurerm provider versions**, producing plan/apply drift that
  is extremely hard to reproduce and debug ("works on my machine").
- There was no CI gate to catch a stale or missing lock file before merge.
- Nothing forced a deliberate, reviewed decision when the provider was
  bumped — bumps happened implicitly on whoever ran `terraform init` next.

For an enterprise landing-zone product, **reproducibility and auditability
of infrastructure changes are non-negotiable**: a provider bump is a change
to the platform's behavior and must go through the same review as any other
change, not happen silently between two `terraform apply` runs.

### Decision
1. **Commit `.terraform.lock.hcl` for every root module** (`environments/*`
   and `examples/*`). Root modules are the only place Terraform actually
   resolves and locks providers for a given state, so this is where the
   lock file has meaning.
   `modules/*` are reusable, non-deployed child modules — Terraform never
   inits/applies them standalone in this repo, so their lock files are
   noise and remain git-ignored.
2. **`make clean` no longer deletes lock files.** It now only clears
   `.terraform/` cache dirs, `*.tfplan`, and (for hygiene only) the
   *non-versioned* lock files under `modules/*`.
3. Two new Make targets formalize the lock file lifecycle:
   - `make lock` — regenerates lock files for all root modules, including
     hashes for `linux_amd64`, `darwin_amd64`, `darwin_arm64`, and
     `windows_amd64` (engineers deploy from Linux CI, macOS Intel/Apple
     Silicon laptops, and occasionally Windows).
   - `make lock-check` — runs `terraform init -lockfile=readonly` against
     every root module; fails if a lock file is missing, stale, or doesn't
     match the declared constraints.
4. **CI enforces lock file consistency on every PR** (`terraform-ci.yml`,
   job `lock-consistency`): fails the build if a root module's lock file is
   missing or does not cover all four target platforms, and fails
   `terraform init -lockfile=readonly` if the lock file doesn't match
   `versions.tf`.
5. **Version constraint stays at `~> 4.15`** (not pinned to `= 4.15.x`) but
   the *lock file*, not the constraint, is now the actual reproducibility
   mechanism — this is the standard Terraform pattern (constraint = allowed
   range, lock file = exact resolved version). This preserves the ability
   to `terraform init -upgrade` deliberately without editing every
   `versions.tf`, while guaranteeing that day-to-day `init`/`apply` always
   reuses the committed, reviewed version.
6. **Controlled bump policy via Renovate** (`renovate.json`): a scheduled,
   grouped PR proposes azurerm lock file / constraint updates weekly; major
   version bumps require explicit dashboard approval before Renovate opens
   the PR. This turns provider upgrades into an auditable, reviewable
   change instead of an implicit side effect of `terraform init`.

### Rationale
- Matches HashiCorp's documented model: *constraints* express intent
  ("any 4.x from 4.15"), *lock file* freezes the actual resolved version +
  checksums per platform. Deleting the lock file defeats the entire
  mechanism.
- Committing per-environment lock files (rather than one shared lock file)
  keeps `prod` upgrade-isolated from `dev`: a client's prod environment
  won't silently pick up a new provider version just because `dev` was
  reinitialized.
- Multi-platform hashes are required because engineers and CI runners are
  not all on the same OS/arch; without them, `terraform init` fails for
  anyone not on the exact platform that generated the lock file.
- Renovate (vs. Dependabot) was chosen because it has first-class Terraform
  provider/lock file support (`lockFileMaintenance`) and flexible grouping
  rules, avoiding PR spam while still surfacing every change for review.

### Trade-offs
- Lock files add ~15-20 lines of diff noise per environment on every
  provider bump; mitigated by grouping via Renovate so it's one clean PR,
  not N.
- Engineers must run `make lock` (not just `terraform init`) after changing
  `versions.tf` or when Renovate can't run, and commit the result — this is
  now enforced by CI (`make lock-check` / `lock-consistency` job) so it
  cannot be silently forgotten.
- Slightly slower `terraform init` in CI (`-lockfile=readonly` disallows
  fallback resolution), which is the intended behavior: any mismatch must
  fail loudly rather than silently re-resolve.
