# ---------------------------------------------------------------------------
# Production Environment — Main
# Fully hardened: private cluster, private endpoints, resource locks, 
# full monitoring with alerts, maintenance windows, zone-redundant
# ---------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.default_tags
}

# Resource lock — prevent accidental deletion of the resource group
resource "azurerm_management_lock" "rg" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Production resource group — protected from accidental deletion."
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  vnet_name          = local.vnet_name
  vnet_address_space = ["10.103.0.0/16"]

  subnets = {
    "snet-aks-nodes" = {
      address_prefixes = ["10.103.0.0/20"]
    }
    "snet-private-endpoints" = {
      address_prefixes                  = ["10.103.16.0/24"]
      private_endpoint_network_policies = "Enabled"
    }
    "snet-appgw" = {
      address_prefixes = ["10.103.17.0/24"]
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
          name                       = "AllowAzureLoadBalancer"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
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
    "nsg-private-endpoints" = {
      subnet_key = "snet-private-endpoints"
      rules = [
        {
          name                       = "AllowVnetInbound"
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
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# Private DNS
# ---------------------------------------------------------------------------

module "private_dns" {
  source = "../../modules/private-dns"

  resource_group_name = azurerm_resource_group.this.name

  dns_zones = {
    "privatelink.azurecr.io" = {
      vnet_links = [{
        name               = "acr-link"
        virtual_network_id = module.networking.vnet_id
      }]
    }
    "privatelink.vaultcore.azure.net" = {
      vnet_links = [{
        name               = "kv-link"
        virtual_network_id = module.networking.vnet_id
      }]
    }
  }

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# Log Analytics
# ---------------------------------------------------------------------------

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = local.log_analytics_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  retention_in_days   = 90

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# Identities
# ---------------------------------------------------------------------------

module "identities" {
  source = "../../modules/identities"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  managed_identities = {
    "id-aks-${local.name_prefix}"     = {}
    "id-kubelet-${local.name_prefix}" = {}
  }

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# Key Vault
# ---------------------------------------------------------------------------

module "keyvault" {
  source = "../../modules/keyvault"

  name                = local.keyvault_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  # Hardened network config
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.networking.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]

  enable_diagnostics         = true
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# Container Registry
# ---------------------------------------------------------------------------

module "acr" {
  source = "../../modules/acr"

  name                          = local.acr_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Premium"
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  retention_policy_days         = 90

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.networking.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.azurecr.io"]

  enable_diagnostics         = true
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# AKS Cluster
# ---------------------------------------------------------------------------

module "aks" {
  source = "../../modules/aks"

  cluster_name        = local.aks_cluster_name
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  location            = azurerm_resource_group.this.location

  # Networking
  vnet_subnet_id = module.networking.subnet_ids["snet-aks-nodes"]

  # Private Cluster — fully private in production
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false

  # Identity
  identity_type             = "UserAssigned"
  user_assigned_identity_id = module.identities.identity_ids["id-aks-${local.name_prefix}"]
  admin_group_object_ids    = var.admin_group_object_ids

  # Production-grade node pools
  default_node_pool = {
    name                         = "system"
    vm_size                      = "Standard_D4s_v5"
    min_count                    = 3
    max_count                    = 6
    auto_scaling_enabled         = true
    os_disk_size_gb              = 128
    os_sku                       = "AzureLinux"
    only_critical_addons_enabled = true
    zones                        = ["1", "2", "3"]
  }

  node_pools = {
    "workload" = {
      vm_size              = "Standard_D4s_v5"
      min_count            = 3
      max_count            = 20
      auto_scaling_enabled = true
      os_sku               = "AzureLinux"
      node_labels          = { "workload-type" = "general" }
    }
    "memory" = {
      vm_size              = "Standard_E4s_v5"
      min_count            = 0
      max_count            = 10
      auto_scaling_enabled = true
      os_sku               = "AzureLinux"
      node_labels          = { "workload-type" = "memory-intensive" }
      node_taints          = ["workload-type=memory-intensive:NoSchedule"]
    }
  }

  # Monitoring
  log_analytics_workspace_id = module.log_analytics.workspace_id

  # SLA-backed cluster
  sku_tier = "Standard"

  # Maintenance windows — weekends only
  maintenance_window = {
    allowed = [
      { day = "Saturday", hours = [0, 1, 2, 3, 4, 5] },
      { day = "Sunday", hours = [0, 1, 2, 3, 4, 5] }
    ]
  }

  tags = local.default_tags
}

# ---------------------------------------------------------------------------
# ACR Pull
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity.object_id
}

# ---------------------------------------------------------------------------
# Monitoring & Alerts
# ---------------------------------------------------------------------------

module "monitor" {
  source = "../../modules/monitor"

  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
  aks_cluster_id             = module.aks.cluster_id

  enable_diagnostic_settings = true
  enable_alerts              = true
  alert_email_receivers      = var.alert_email_receivers

  tags = local.default_tags
}
