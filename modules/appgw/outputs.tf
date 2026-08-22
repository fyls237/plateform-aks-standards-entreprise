# ---------------------------------------------------------------------------
# Application Gateway Module — Outputs
# ---------------------------------------------------------------------------

output "application_gateway_id" {
  description = "Resource ID of the Application Gateway."
  value       = var.ingress_type == "agic" ? azurerm_application_gateway.agic[0].id : azurerm_application_gateway.nginx[0].id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway."
  value       = var.ingress_type == "agic" ? azurerm_application_gateway.agic[0].name : azurerm_application_gateway.nginx[0].name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway."
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_id" {
  description = "Resource ID of the Public IP."
  value       = azurerm_public_ip.pip.id
}
