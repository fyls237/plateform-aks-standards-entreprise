locals {
  environment = var.environment
  project     = var.project
  location    = var.location

  location_short = {
    "westeurope"  = "weu"
    "northeurope" = "neu"
    "eastus"      = "eus"
    "eastus2"     = "eu2"
    "westus2"     = "wu2"
    "centralus"   = "cus"
  }

  loc = try(local.location_short[local.location], substr(replace(local.location, " ", ""), 0, 4))

  name_prefix = "${local.project}-${local.environment}-${local.loc}"

  resource_group_name = "rg-${local.name_prefix}"
  vnet_name           = "vnet-${local.name_prefix}"
  aks_cluster_name    = "aks-${local.name_prefix}"
  acr_name            = replace("acr${local.project}${local.environment}${local.loc}", "-", "")
  keyvault_name       = "kv-${local.name_prefix}"
  log_analytics_name  = "log-${local.name_prefix}"

  default_tags = merge({
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "terraform"
    Repository  = "platform-aks-standards-enterprise"
  }, var.tags)
}
