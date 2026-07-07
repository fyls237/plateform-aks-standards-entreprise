# ---------------------------------------------------------------------------
# Enterprise Example
# Full-featured deployment: all modules, private endpoints, monitoring
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.12.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.15"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "location" {
  type    = string
  default = "westeurope"
}

variable "project" {
  type    = string
  default = "enterprise"
}

variable "admin_group_object_ids" {
  type    = list(string)
  default = []
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-ent"
  tags = {
    Environment = "enterprise-example"
    Project     = var.project
    ManagedBy   = "terraform"
    Example     = "enterprise"
  }
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  vnet_name          = "vnet-${local.name_prefix}"
  vnet_address_space = ["10.201.0.0/16"]

  subnets = {
    "snet-aks-nodes" = {
      address_prefixes = ["10.201.0.0/20"]
    }
    "snet-private-endpoints" = {
      address_prefixes                  = ["10.201.16.0/24"]
      private_endpoint_network_policies = "Enabled"
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

  tags = local.tags
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

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Log Analytics
# ---------------------------------------------------------------------------

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = "log-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  retention_in_days   = 60

  tags = local.tags
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

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Key Vault (with Private Endpoint)
# ---------------------------------------------------------------------------

module "keyvault" {
  source = "../../modules/keyvault"

  name                = "kv-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.networking.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]

  enable_diagnostics         = true
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.tags
}

# ---------------------------------------------------------------------------
# ACR (with Private Endpoint)
# ---------------------------------------------------------------------------

module "acr" {
  source = "../../modules/acr"

  name                          = replace("acr${var.project}ent", "-", "")
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Premium"
  public_network_access_enabled = false

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.networking.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.azurecr.io"]

  enable_diagnostics         = true
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.tags
}

# ---------------------------------------------------------------------------
# AKS
# ---------------------------------------------------------------------------

module "aks" {
  source = "../../modules/aks"

  cluster_name        = "aks-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  location            = azurerm_resource_group.this.location

  vnet_subnet_id          = module.networking.subnet_ids["snet-aks-nodes"]
  private_cluster_enabled = false

  identity_type             = "UserAssigned"
  user_assigned_identity_id = module.identities.identity_ids["id-aks-${local.name_prefix}"]
  admin_group_object_ids    = var.admin_group_object_ids

  default_node_pool = {
    vm_size              = "Standard_D4s_v5"
    min_count            = 2
    max_count            = 5
    auto_scaling_enabled = true
    os_sku               = "AzureLinux"
    zones                = ["1", "2", "3"]
  }

  node_pools = {
    "workload" = {
      vm_size              = "Standard_D4s_v5"
      min_count            = 2
      max_count            = 10
      auto_scaling_enabled = true
      os_sku               = "AzureLinux"
    }
  }

  log_analytics_workspace_id = module.log_analytics.workspace_id
  sku_tier                   = "Standard"

  tags = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity.object_id
}

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------

module "monitor" {
  source = "../../modules/monitor"

  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
  aks_cluster_id             = module.aks.cluster_id

  enable_alerts = true
  alert_email_receivers = [{
    name          = "platform-team"
    email_address = "platform@example.com"
  }]

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "cluster_name" {
  value = module.aks.cluster_name
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "keyvault_uri" {
  value = module.keyvault.key_vault_uri
}
