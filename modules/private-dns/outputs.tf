# ---------------------------------------------------------------------------
# Private DNS Module — Outputs
# ---------------------------------------------------------------------------

output "zone_ids" {
  description = "Map of DNS zone names to their resource IDs."
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}

output "zone_names" {
  description = "List of Private DNS zone names created."
  value       = [for v in azurerm_private_dns_zone.this : v.name]
}
