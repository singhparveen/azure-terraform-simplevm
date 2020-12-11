provider "azurerm" {
  features {}
}

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_resource_group" "rg01" {
  location = var.location
  name     = "${var.resource_group_name}-RG"
}

module "subnet" {
    source = "./modules/network/subnet"

    subnet_name         = var.subnet_name
    nsg_name            = var.nsg_name
    vnet_name           = var.vnet_name
    location            = azurerm_resource_group.rg01.location
    resource_group_name = azurerm_resource_group.rg01.name
}

module "diagstorage" {
    source = "./modules/storage/storageaccount"
    
    storageaccname        = "tfsta${lower(random_id.storage_account.hex)}"
    location              = azurerm_resource_group.rg01.location
    resource_group_name   = azurerm_resource_group.rg01.name
}

module "simple-vm" {
    source = "./modules/compute/simple-vm"

    resource_group_name           = azurerm_resource_group.rg01.name
    location                      = azurerm_resource_group.rg01.location
    vm_name                       = var.machine_name
    admin_username                = var.admin_username
    admin_password                = var.admin_password
    prefix                        = var.prefix
    storageaccURI                 = module.diagstorage.storage_id
    subnet_id                     = module.subnet.subnet_id
}
