# ---------------------------------------------------------------------------
# AKS Module — Outputs
# ---------------------------------------------------------------------------

output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster API server."
  value       = var.private_cluster_enabled ? azurerm_kubernetes_cluster.this.private_fqdn : azurerm_kubernetes_cluster.this.fqdn
}

output "cluster_identity" {
  description = "Identity block of the AKS cluster."
  value = {
    principal_id = azurerm_kubernetes_cluster.this.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.this.identity[0].tenant_id
  }
}

output "kubelet_identity" {
  description = "Kubelet identity of the AKS cluster."
  value = {
    client_id                 = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
    user_assigned_identity_id = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].user_assigned_identity_id, null)
  }
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity."
  value       = var.oidc_issuer_enabled ? azurerm_kubernetes_cluster.this.oidc_issuer_url : null
}

output "node_resource_group" {
  description = "Auto-generated resource group for AKS node resources."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "Kubernetes API server host."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

output "node_pool_ids" {
  description = "Map of additional node pool names to their resource IDs."
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.this : k => v.id }
}
