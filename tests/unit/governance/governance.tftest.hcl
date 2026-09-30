mock_provider "azurerm" {
  override_during = plan

  mock_data "azurerm_policy_definition" {
    defaults = {
      id = "/providers/Microsoft.Authorization/policyDefinitions/not-allowed-resources"
    }
  }
}

override_data {
  target = data.azurerm_policy_definition.not_allowed_resources
  values = {
    id = "/providers/Microsoft.Authorization/policyDefinitions/not-allowed-resources"
  }
}

override_data {
  target = data.azurerm_policy_definition.allowed_locations
  values = {
    id = "/providers/Microsoft.Authorization/policyDefinitions/allowed-locations"
  }
}

run "creates_expected_policy_assignments" {
  command = plan

  module {
    source = "../../../modules/governance"
  }

  variables {
    name_prefix               = "test-prod-weu"
    resource_group_id         = "/subscriptions/test/resourceGroups/rg-test"
    compliance_initiative_ids = ["/providers/Microsoft.Authorization/policySetDefinitions/initiative-test"]
    allowed_locations         = ["westeurope", "northeurope"]
    exempt_public_ip_ids = [
      "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-test"
    ]
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.compliance["/providers/Microsoft.Authorization/policySetDefinitions/initiative-test"].policy_definition_id == "/providers/Microsoft.Authorization/policySetDefinitions/initiative-test"
    error_message = "The compliance initiative must be assigned using the configured policy set ID."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.compliance["/providers/Microsoft.Authorization/policySetDefinitions/initiative-test"].name == "pol-initiative-test" && azurerm_resource_group_policy_assignment.compliance["/providers/Microsoft.Authorization/policySetDefinitions/initiative-test"].resource_group_id == "/subscriptions/test/resourceGroups/rg-test"
    error_message = "The compliance initiative must use the expected stable name and resource group scope."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.compliance["/providers/Microsoft.Authorization/policySetDefinitions/initiative-test"].identity[0].type == "SystemAssigned"
    error_message = "Compliance initiatives must use a system-assigned identity for remediation."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.deny_pip[0].parameters == jsonencode({ listOfResourceTypesNotAllowed = { value = ["Microsoft.Network/publicIPAddresses"] } })
    error_message = "The deny-public-IP assignment must deny public IP resource types."
  }

  assert {
    condition     = length(azurerm_resource_group_policy_assignment.deny_pip[0].not_scopes) == 1 && contains(azurerm_resource_group_policy_assignment.deny_pip[0].not_scopes, "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-test")
    error_message = "The deny-public-IP assignment must preserve its exemptions."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.deny_pip[0].policy_definition_id == "/providers/Microsoft.Authorization/policyDefinitions/not-allowed-resources"
    error_message = "The deny-public-IP assignment must use the not-allowed-resources policy."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.allowed_locations.parameters == jsonencode({ listOfAllowedLocations = { value = ["westeurope", "northeurope"] } })
    error_message = "The allowed-locations assignment must contain the configured regions."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.allowed_locations.policy_definition_id == "/providers/Microsoft.Authorization/policyDefinitions/allowed-locations"
    error_message = "The allowed-locations assignment must use the allowed-locations policy."
  }
}

run "does_not_enable_subscription_defender_by_default" {
  command = plan

  module {
    source = "../../../modules/governance"
  }

  variables {
    name_prefix                        = "test-dev-weu"
    resource_group_id                  = "/subscriptions/test/resourceGroups/rg-test-dev"
    compliance_initiative_ids          = []
    deny_public_ip_enabled             = false
    enable_subscription_defender_plans = false
  }

  assert {
    condition     = length(azurerm_resource_group_policy_assignment.deny_pip) == 0
    error_message = "The public-IP deny assignment must be optional."
  }

  assert {
    condition     = length(azurerm_security_center_subscription_pricing.containers) == 0 && length(azurerm_security_center_subscription_pricing.keyvault) == 0 && length(azurerm_security_center_subscription_pricing.acr) == 0
    error_message = "Subscription Defender plans must remain disabled unless explicitly requested."
  }
}
