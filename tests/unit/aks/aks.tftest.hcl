mock_provider "azurerm" {
  override_during = plan
}

run "enables_preprod_and_production_security_controls" {
  command = plan

  module {
    source = "../../../modules/aks"
  }

  variables {
    cluster_name            = "aks-test-prod-weu"
    resource_group_name     = "rg-test-prod-weu"
    resource_group_id       = "/subscriptions/test/resourceGroups/rg-test-prod-weu"
    location                = "westeurope"
    vnet_subnet_id          = "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-aks"
    identity_type           = "SystemAssigned"
    azure_rbac_enabled      = true
    local_account_disabled  = true
    private_cluster_enabled = true
    private_dns_zone_id     = "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.azure_active_directory_role_based_access_control[0].azure_rbac_enabled
    error_message = "AKS must have Azure RBAC enabled."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.local_account_disabled
    error_message = "Production AKS must disable the local account."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.private_cluster_enabled
    error_message = "Production AKS must be a private cluster."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.private_dns_zone_id == "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
    error_message = "Production AKS must use the configured private DNS zone."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.dns_prefix == null && azurerm_kubernetes_cluster.aks.dns_prefix_private_cluster == "aks-test-prod-weu"
    error_message = "A custom private AKS DNS zone must use the private cluster DNS prefix."
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.oidc_issuer_enabled && azurerm_kubernetes_cluster.aks.workload_identity_enabled && azurerm_kubernetes_cluster.aks.azure_policy_enabled
    error_message = "Production AKS must enable OIDC, Workload Identity, and Azure Policy."
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.aks.ingress_application_gateway) == 0
    error_message = "Production must use the NGINX ingress pattern rather than the AGIC add-on."
  }
}

run "restricts_public_dev_and_test_api_access" {
  command = plan

  module {
    source = "../../../modules/aks"
  }

  variables {
    cluster_name                    = "aks-test-dev-weu"
    resource_group_name             = "rg-test-dev-weu"
    resource_group_id               = "/subscriptions/test/resourceGroups/rg-test-dev-weu"
    location                        = "westeurope"
    vnet_subnet_id                  = "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-aks"
    identity_type                   = "SystemAssigned"
    private_cluster_enabled         = false
    api_server_authorized_ip_ranges = ["203.0.113.0/24"]
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.private_cluster_enabled == false
    error_message = "Development and test AKS clusters should remain public."
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.aks.api_server_access_profile[0].authorized_ip_ranges) == 1 && contains(azurerm_kubernetes_cluster.aks.api_server_access_profile[0].authorized_ip_ranges, "203.0.113.0/24")
    error_message = "Public development and test AKS clusters must restrict API access to authorized ranges."
  }
}

run "configures_preprod_agic_integration" {
  command = plan

  module {
    source = "../../../modules/aks"
  }

  variables {
    cluster_name            = "aks-test-preprod-weu"
    resource_group_name     = "rg-test-preprod-weu"
    resource_group_id       = "/subscriptions/test/resourceGroups/rg-test-preprod-weu"
    location                = "westeurope"
    vnet_subnet_id          = "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-aks"
    identity_type           = "SystemAssigned"
    private_cluster_enabled = true
    private_dns_zone_id     = "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
    ingress_type            = "agic"
    appgw_id                = "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/applicationGateways/agw-test"
    node_pools = {
      workload = {}
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].gateway_id == "/subscriptions/test/resourceGroups/rg-test/providers/Microsoft.Network/applicationGateways/agw-test"
    error_message = "Preprod AGIC must target the configured Application Gateway."
  }
}
