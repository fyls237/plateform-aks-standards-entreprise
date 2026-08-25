variable "name_prefix" {
  description = "Prefix for the resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "bastion_subnet_id" {
  description = "Resource ID of the AzureBastionSubnet."
  type        = string
}

variable "jumphost_subnet_id" {
  description = "Resource ID of the subnet for the Jumphost VM."
  type        = string
}

variable "bastion_sku" {
  description = "The SKU of the Bastion Host. Options: Basic, Standard, Premium."
  type        = string
  default     = "Standard"
}

variable "jumphost_vm_size" {
  description = "VM size for the Jumphost."
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_group_object_ids" {
  description = "List of Azure AD Group Object IDs to grant 'Virtual Machine Administrator Login' access on the Jumphost."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for audit logs and metrics."
  type        = string
}
