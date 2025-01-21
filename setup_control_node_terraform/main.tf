############### RG #################
data azurerm_subscription "current" { }

resource "azurerm_resource_group" "example" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "control" {
  name                = "control-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "control" {
  name                 = "control-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.control.name
  address_prefixes     = ["172.16.2.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "control-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.control.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_public_ip" "control" {
  name                = "control-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "control-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.control.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.control.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "control-node"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1ms"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  computer_name  = "control"
  admin_username = "azureadmin"
  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "control" {
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id       = azurerm_linux_virtual_machine.example.identity[0].principal_id
}
