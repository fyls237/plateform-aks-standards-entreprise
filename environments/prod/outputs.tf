output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.cluster_id
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity."
  value       = module.aks.oidc_issuer_url
}

output "acr_login_server" {
  description = "Login server URL of the Container Registry."
  value       = module.acr.acr_login_server
}

output "keyvault_uri" {
  description = "URI of the Key Vault."
  value       = module.keyvault.key_vault_uri
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.networking.vnet_id
}
