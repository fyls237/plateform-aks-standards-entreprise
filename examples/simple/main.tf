# ---------------------------------------------------------------------------
# Simple Example
# Minimal AKS deployment for quick evaluation
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
  features {}
}

data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "project" {
  description = "Project name."
  type        = string
  default     = "aksquick"
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-simple"
  tags = {
    Environment = "example"
    Project     = var.project
    ManagedBy   = "terraform"
    Example     = "simple"
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
# Networking (minimal)
# ---------------------------------------------------------------------------

module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  vnet_name          = "vnet-${local.name_prefix}"
  vnet_address_space = ["10.200.0.0/16"]

  subnets = {
    "snet-aks" = {
      address_prefixes = ["10.200.0.0/20"]
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
  retention_in_days   = 30

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------

module "identities" {
  source = "../../modules/identities"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  managed_identities = {
    "id-aks-${local.name_prefix}" = {}
  }

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

  vnet_subnet_id            = module.networking.subnet_ids["snet-aks"]
  identity_type             = "UserAssigned"
  user_assigned_identity_id = module.identities.identity_ids["id-aks-${local.name_prefix}"]

  default_node_pool = {
    vm_size              = "Standard_D2s_v5"
    min_count            = 1
    max_count            = 3
    auto_scaling_enabled = true
    os_sku               = "AzureLinux"
  }

  log_analytics_workspace_id = module.log_analytics.workspace_id
  sku_tier                   = "Free"

  tags = local.tags
}

# ---------------------------------------------------------------------------
# ACR
# ---------------------------------------------------------------------------

module "acr" {
  source = "../../modules/acr"

  name                = replace("acr${var.project}simple", "-", "")
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"

  aks_principal_id = module.aks.kubelet_identity.object_id

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "cluster_name" {
  value = module.aks.cluster_name
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${module.aks.cluster_name}"
}
