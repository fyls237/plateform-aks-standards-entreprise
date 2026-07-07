# ---------------------------------------------------------------------------
# Private Cluster Example
# AKS with private API server, private endpoints for ACR and Key Vault
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
  default = "privateaks"
}

variable "admin_group_object_ids" {
  type    = list(string)
  default = []
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-priv"
  tags = {
    Environment = "private-cluster-example"
    Project     = var.project
    ManagedBy   = "terraform"
    Example     = "private-cluster"
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
  vnet_address_space = ["10.202.0.0/16"]

  subnets = {
    "snet-aks-nodes" = {
      address_prefixes = ["10.202.0.0/20"]
    }
    "snet-private-endpoints" = {
      address_prefixes                  = ["10.202.16.0/24"]
      private_endpoint_network_policies = "Enabled"
    }
  }

  network_security_groups = {
    "nsg-aks-nodes" = {
      subnet_key = "snet-aks-nodes"
      rules = [
        {
          name                       = "AllowVnetInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          destination_port_range     = "*"
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

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Private DNS Zones
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
# Supporting Services
# ---------------------------------------------------------------------------

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = "log-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  tags = local.tags
}

module "identities" {
  source = "../../modules/identities"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  managed_identities = {
    "id-aks-${local.name_prefix}" = {}
  }

  tags = local.tags
}

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

  tags = local.tags
}

module "acr" {
  source = "../../modules/acr"

  name                          = replace("acr${var.project}priv", "-", "")
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "Premium"
  public_network_access_enabled = false

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.networking.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = module.private_dns.zone_ids["privatelink.azurecr.io"]

  tags = local.tags
}

# ---------------------------------------------------------------------------
# AKS — Private Cluster
# ---------------------------------------------------------------------------

module "aks" {
  source = "../../modules/aks"

  cluster_name        = "aks-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id
  location            = azurerm_resource_group.this.location

  vnet_subnet_id = module.networking.subnet_ids["snet-aks-nodes"]

  # Private cluster configuration
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = "System"

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
# Outputs
# ---------------------------------------------------------------------------

output "cluster_name" {
  value = module.aks.cluster_name
}

output "private_fqdn" {
  value       = module.aks.cluster_fqdn
  description = "Private FQDN — accessible only from within the VNet or peered networks."
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "note" {
  value = "This is a private cluster. Use 'az aks command invoke' or a jumpbox within the VNet to access the API server."
}
