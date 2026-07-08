# ---------------------------------------------------------------------------
# Identities Module — Main
# User-Assigned Managed Identities, Role Assignments, Federated Credentials
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "assigned_identity" {
  for_each = var.managed_identities

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, each.value.tags)
}

# ---------------------------------------------------------------------------
# Role Assignments
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "role_assignment" {
  count = length(var.role_assignments)

  scope                = var.role_assignments[count.index].scope
  role_definition_name = var.role_assignments[count.index].role_definition_name
  principal_id         = azurerm_user_assigned_identity.assigned_identity[var.role_assignments[count.index].identity_key].principal_id
}

# ---------------------------------------------------------------------------
# Federated Identity Credentials (Workload Identity)
# ---------------------------------------------------------------------------

resource "azurerm_federated_identity_credential" "federated_identity_credential" {
  count = length(var.federated_identity_credentials)

  name                = var.federated_identity_credentials[count.index].name
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.assigned_identity[var.federated_identity_credentials[count.index].identity_key].id
  issuer              = var.federated_identity_credentials[count.index].issuer
  subject             = var.federated_identity_credentials[count.index].subject
  audience            = var.federated_identity_credentials[count.index].audiences
}
