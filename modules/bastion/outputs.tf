output "bastion_id" {
  description = "Resource ID of the Bastion Host."
  value       = azurerm_bastion_host.this.id
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host."
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_public_ip_id" {
  description = "Resource ID of the Bastion Public IP."
  value       = azurerm_public_ip.bastion.id
}

output "jumphost_vm_id" {
  description = "Resource ID of the Jumphost Virtual Machine."
  value       = azurerm_linux_virtual_machine.jump.id
}

output "jumphost_private_ip" {
  description = "Private IP address of the Jumphost Virtual Machine."
  value       = azurerm_network_interface.jump.private_ip_address
}
