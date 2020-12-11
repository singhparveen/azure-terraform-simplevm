resource "azurerm_public_ip" "static" {
  name                = "${var.prefix}-client-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "primary" {
  name                = join("-", [var.prefix, "client-nic"])
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static.id
  }
}

resource "azurerm_windows_virtual_machine" "simple-server" {
  name                     = var.vm_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = var.vm_size
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.primary.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = join("_", [var.vm_name, "OsDisk"])
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
