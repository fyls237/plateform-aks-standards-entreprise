mock_provider "azurerm" {
  override_during = plan

  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/test/resourceGroups/rg-test-prod-weu/providers/Microsoft.Network/virtualNetworks/vnet-test-prod-weu/subnets/snet-aks-nodes"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/test/resourceGroups/rg-test-prod-weu/providers/Microsoft.Network/networkSecurityGroups/nsg-aks-nodes"
    }
  }
}

run "enforces_default_deny_and_subnet_association" {
  command = plan

  module {
    source = "../../../modules/networking"
  }

  variables {
    resource_group_name = "rg-test-prod-weu"
    location            = "westeurope"
    vnet_name           = "vnet-test-prod-weu"
    vnet_address_space  = ["10.103.0.0/16"]

    subnets = {
      "snet-aks-nodes" = {
        address_prefixes = ["10.103.0.0/20"]
      }
    }

    network_security_groups = {
      "nsg-aks-nodes" = {
        subnet_key = "snet-aks-nodes"
        rules = [
          {
            name                       = "AllowHTTPSFromVnet"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            destination_port_range     = "443"
            source_address_prefix      = "VirtualNetwork"
            destination_address_prefix = "VirtualNetwork"
          },
          {
            name                       = "DenyAllInbound"
            priority                   = 4096
            direction                  = "Inbound"
            access                     = "Deny"
            protocol                   = "*"
            destination_port_range     = "*"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
          }
        ]
      }
    }

    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/test/resourceGroups/rg-test-prod-weu/providers/Microsoft.OperationalInsights/workspaces/law-test"
  }

  assert {
    condition = contains([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule.name
    ], "DenyAllInbound")
    error_message = "The AKS node NSG must include a default deny inbound rule."
  }

  assert {
    condition = one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
    ]).priority == 4096
    error_message = "The default deny inbound rule must have priority 4096."
  }

  assert {
    condition = one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
      ]).direction == "Inbound" && one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
      ]).access == "Deny" && one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
    ]).protocol == "*"
    error_message = "The default deny inbound rule must deny every protocol."
  }

  assert {
    condition = one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
      ]).source_address_prefix == "*" && one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
      ]).destination_address_prefix == "*" && one([
      for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule
      if rule.name == "DenyAllInbound"
    ]).destination_port_range == "*"
    error_message = "The default deny inbound rule must cover all addresses and ports."
  }

  assert {
    condition     = azurerm_subnet_network_security_group_association.subnet_network_security_group_association["nsg-aks-nodes"].subnet_id == azurerm_subnet.subnet["snet-aks-nodes"].id
    error_message = "The AKS node NSG must be associated with the AKS node subnet."
  }

  assert {
    condition = length(azurerm_monitor_diagnostic_setting.nsg["nsg-aks-nodes"].enabled_log) == 2 && contains([
      for log in azurerm_monitor_diagnostic_setting.nsg["nsg-aks-nodes"].enabled_log : log.category
      ], "NetworkSecurityGroupEvent") && contains([
      for log in azurerm_monitor_diagnostic_setting.nsg["nsg-aks-nodes"].enabled_log : log.category
    ], "NetworkSecurityGroupRuleCounter")
    error_message = "Preprod and production NSGs must export both diagnostic log categories."
  }
}

run "keeps_dev_and_test_networking_minimal" {
  command = plan

  module {
    source = "../../../modules/networking"
  }

  variables {
    resource_group_name = "rg-test-dev-weu"
    location            = "westeurope"
    vnet_name           = "vnet-test-dev-weu"
    vnet_address_space  = ["10.100.0.0/16"]

    subnets = {
      "snet-aks-nodes" = {
        address_prefixes = ["10.100.0.0/20"]
      }
    }

    network_security_groups = {
      "nsg-aks-nodes" = {
        subnet_key = "snet-aks-nodes"
        rules = [
          {
            name                       = "AllowHTTPS"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            destination_port_range     = "443"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
          }
        ]
      }
    }

    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/test/resourceGroups/rg-test-dev-weu/providers/Microsoft.OperationalInsights/workspaces/law-test"
  }

  assert {
    condition     = length(azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule) == 1 && one([for rule in azurerm_network_security_group.nsg["nsg-aks-nodes"].security_rule : rule]).name == "AllowHTTPS"
    error_message = "Development and test should keep the configured minimal HTTPS rule set."
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.nsg["nsg-aks-nodes"].enabled_log) == 2
    error_message = "Development and test networking must still enable NSG diagnostics."
  }
}
