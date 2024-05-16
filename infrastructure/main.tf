terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "keacloud" {
  name     = "keacloud-resources"
  location = "North Europe"
}

resource "azurerm_virtual_network" "keacloud" {
  name                = "keacloud-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.keacloud.location
  resource_group_name = azurerm_resource_group.keacloud.name
}

resource "azurerm_subnet" "keacloud" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.keacloud.name
  virtual_network_name = azurerm_virtual_network.keacloud.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "keacloud" {
  name                = "keacloud-publicip"
  location            = azurerm_resource_group.keacloud.location
  resource_group_name = azurerm_resource_group.keacloud.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "keacloud" {
  name                = "keacloud-nic"
  location            = azurerm_resource_group.keacloud.location
  resource_group_name = azurerm_resource_group.keacloud.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.keacloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.keacloud.id
  }
}

resource "azurerm_linux_virtual_machine" "keacloud" {
  name                = "main-vm"
  resource_group_name = azurerm_resource_group.keacloud.name
  location            = azurerm_resource_group.keacloud.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.keacloud.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  disable_password_authentication = true
}

resource "azurerm_network_security_group" "keacloud_nsg" {
  name                = "keacloud-nsg"
  location            = azurerm_resource_group.keacloud.location
  resource_group_name = azurerm_resource_group.keacloud.name

  security_rule {
    name                       = "allow-80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_security_rule" "keacloud_ssh_rule" {
  name                        = "SSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.keacloud_nsg.name
  resource_group_name         = azurerm_resource_group.keacloud.name
}

resource "azurerm_dns_zone" "keacloud" {
  name                = "keacloud.dk"
  resource_group_name = azurerm_resource_group.keacloud.name
}


resource "azurerm_dns_a_record" "keacloud" {
  name                = "www"
  zone_name           = azurerm_dns_zone.keacloud.name
  resource_group_name = azurerm_resource_group.keacloud.name
  ttl                 = 300
  records             = [azurerm_public_ip.keacloud.ip_address]
}
