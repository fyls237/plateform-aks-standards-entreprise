# ---------------------------------------------------------------------------
# Azure Policy & Governance Module
# ---------------------------------------------------------------------------

# 1. Assign Regulatory Compliance Initiatives (e.g., MCSB, HIPAA) dynamically by ID
# Using IDs prevents issues with Microsoft renaming policies and slow data sources.
resource "azurerm_resource_group_policy_assignment" "compliance" {
  # We use the last segment of the ID (the GUID) to make a unique, stable assignment name.
  for_each             = toset(var.compliance_initiative_ids)

  name                 = substr("pol-${split("/", each.value)[length(split("/", each.value)) - 1]}", 0, 24)
  resource_group_id    = var.resource_group_id
  policy_definition_id = each.value
  description          = "Assignment of Regulatory Initiative for Zero-Trust Governance"

  # Ensure Managed Identity is used if the policy requires remediation tasks
  identity {
    type = "SystemAssigned"
  }
}

# 3. Deny Public IPs (Zero-Trust strict boundary)
# Fetch the built-in "Not allowed resource types" policy
data "azurerm_policy_definition" "not_allowed_resources" {
  display_name = "Not allowed resource types"
}

resource "azurerm_resource_group_policy_assignment" "deny_pip" {
  count = var.deny_public_ip_enabled ? 1 : 0

  name                 = substr("deny-pip-${var.name_prefix}", 0, 24)
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.not_allowed_resources.id
  description          = "Natively block the creation of Public IPs to enforce private-only access, except for explicitly authorized edge resources (AppGW, Bastion)."

  parameters = jsonencode({
    listOfResourceTypesNotAllowed = {
      value = [
        "Microsoft.Network/publicIPAddresses"
      ]
    }
  })

  # Exempt the authorized Public IPs (Bastion, Application Gateway)
  not_scopes = var.exempt_public_ip_ids
}

# 4. Enforce Data Sovereignty (Allowed Locations)
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = substr("loc-${var.name_prefix}", 0, 24)
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  description          = "Enforces Data Sovereignty by restricting resource deployments to allowed regions."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

# ---------------------------------------------------------------------------
# Defender for Cloud (Subscription Level Options)
# ---------------------------------------------------------------------------

# If the deploying identity has sufficient privileges (Security Admin / Owner),
# we can enable Defender for Cloud plans at the subscription level.
# In a pure Brownfield (Contributor on RG only), this must be false.

resource "azurerm_security_center_subscription_pricing" "containers" {
  count         = var.enable_subscription_defender_plans ? 1 : 0
  tier          = "Standard"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "keyvault" {
  count         = var.enable_subscription_defender_plans ? 1 : 0
  tier          = "Standard"
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_subscription_pricing" "acr" {
  count         = var.enable_subscription_defender_plans ? 1 : 0
  tier          = "Standard"
  resource_type = "ContainerRegistry"
}
