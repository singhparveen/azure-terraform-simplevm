resource "azurerm_virtual_network" "azvnet" {
  name                = var.vnet_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  address_prefix       = "10.0.1.0/24"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.azvnet.name
}

resource "azurerm_network_security_group" "subnsg" {
  name                 = var.nsg_name
  resource_group_name  = var.resource_group_name
  location             = var.location
}

resource "azurerm_network_security_rule" "rdp-rule" {
  name                        = "RDP-PS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnsg.name
}

resource "azurerm_network_security_rule" "http-rule" {
  name                        = "HTTP-PS"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnsg.name
}

resource "azurerm_network_security_rule" "https-rule" {
  name                        = "HTTPS-PS"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnsg.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnsg.id
}