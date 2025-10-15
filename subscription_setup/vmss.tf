# Create a VMSS to be used as an Azure DevOps agent pool
resource "azurerm_linux_virtual_machine_scale_set" "devops" {
  name                            = "vmss-${var.project_acronym}-devops-agents-${var.subscription_env}"
  resource_group_name             = azurerm_resource_group.devops.name
  location                        = local.location
  sku                             = "Standard_D2s_v3"
  admin_username                  = "vmssadmin-${var.project_acronym}-${var.subscription_env}"
  admin_password                  = var.vmss_admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss-devops-agents"
    primary = true

    ip_configuration {
      name      = "ipconfig-vmss-devops-agents"
      primary   = true
      subnet_id = azurerm_subnet.devops.id
    }
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sa["vmss"].primary_blob_endpoint
  }

  tags = local.sub_scope_tags
}
