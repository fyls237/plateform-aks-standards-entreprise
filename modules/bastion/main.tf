# ---------------------------------------------------------------------------
# Azure Bastion Module
# ---------------------------------------------------------------------------

# Bastion Public IP
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bas-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Bastion Host
resource "azurerm_bastion_host" "this" {
  name                = "bas-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.bastion_sku

  # Standard features (only apply if SKU is Standard)
  tunneling_enabled      = var.bastion_sku == "Standard" ? true : false
  ip_connect_enabled     = var.bastion_sku == "Standard" ? true : false
  file_copy_enabled      = var.bastion_sku == "Standard" ? true : false
  shareable_link_enabled = var.bastion_sku == "Standard" ? true : false

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
  tags = var.tags
}

# Diagnostic Settings (Auditability)
resource "azurerm_monitor_diagnostic_setting" "bastion" {
  name                       = "diag-bas-${var.name_prefix}"
  target_resource_id         = azurerm_bastion_host.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "bastion_pip" {
  name                       = "diag-pip-bas-${var.name_prefix}"
  target_resource_id         = azurerm_public_ip.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DDoSProtectionNotifications"
  }
  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }
  enabled_log {
    category = "DDoSMitigationReports"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------------------
# Secure Jumphost (Linux)
# ---------------------------------------------------------------------------

# Jumphost NIC
resource "azurerm_network_interface" "jump" {
  name                = "nic-jump-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.jumphost_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

# Generate a dummy SSH key for initial VM creation
# (Azure requires an SSH key or password initially, but we enforce AAD login)
resource "tls_private_key" "dummy" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Jumphost VM
resource "azurerm_linux_virtual_machine" "jump" {
  # checkov:skip=CKV_AZURE_50: "VM Extensions are required to install the Microsoft AAD SSH Login extension for Zero-Trust access."
  name                = "vm-jump-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.jumphost_vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.jump.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.dummy.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Vulnerability Management: Automatic OS Patching
  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByPlatform"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Cloud-init to install tools
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

    # Install Azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Install kubectl (via native apt repo)
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl

    # Install kubelogin
    sudo az aks install-cli --client-version kubelogin

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  EOF
  )

  # System assigned identity for AAD login
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# AAD Login Extension
resource "azurerm_virtual_machine_extension" "aad_login" {
  # checkov:skip=CKV_AZURE_50: "Microsoft AAD SSH Login extension is required for keyless, Zero-Trust Azure AD authentication."
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.jump.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

# RBAC for AAD Login
resource "azurerm_role_assignment" "jump_admin" {
  for_each             = toset(var.admin_group_object_ids)
  scope                = azurerm_linux_virtual_machine.jump.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = each.value
}
