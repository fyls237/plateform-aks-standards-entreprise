variable "name" {
  description = "Name of the Disk Encryption Set."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Disk Encryption Set."
  type        = string
}

variable "location" {
  description = "Azure region for the Disk Encryption Set and key."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault that stores the customer-managed key."
  type        = string
}

variable "key_name" {
  description = "Name of the customer-managed encryption key."
  type        = string
}

variable "key_type" {
  description = "Key type for the customer-managed encryption key."
  type        = string
  default     = "RSA"

  validation {
    condition     = contains(["RSA", "RSA-HSM"], var.key_type)
    error_message = "key_type must be RSA or RSA-HSM."
  }
}

variable "key_size" {
  description = "RSA key size in bits."
  type        = number
  default     = 4096

  validation {
    condition     = contains([2048, 3072, 4096], var.key_size)
    error_message = "key_size must be 2048, 3072, or 4096."
  }
}

variable "key_opts" {
  description = "Operations allowed for the customer-managed encryption key."
  type        = list(string)
  default     = ["decrypt", "encrypt", "unwrapKey", "wrapKey"]
}

variable "key_rotation_time_before_expiry" {
  description = "Time before key expiry when automatic rotation should occur."
  type        = string
  default     = "P30D"
}

variable "key_expiration" {
  description = "Lifetime of each key version."
  type        = string
  default     = "P2Y"
}

variable "key_notification_before_expiry" {
  description = "Notification period before key expiry."
  type        = string
  default     = "P30D"
}
