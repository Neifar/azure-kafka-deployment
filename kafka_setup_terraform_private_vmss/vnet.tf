############### RG #################
data azurerm_subscription "current" { }

resource "azurerm_resource_group" "example" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "kafka" {
  name                = "kafka-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "kafka" {
  name                 = "kafka-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.kafka.name
  address_prefixes     = ["172.16.1.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "kafka-nsg"
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
  subnet_id                 = azurerm_subnet.kafka.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_virtual_network_peering" "kafka-to-control" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.kafka.name
  remote_virtual_network_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/control_rg/providers/Microsoft.Network/virtualNetworks/control-vnet"
}

resource "azurerm_virtual_network_peering" "control-to-kafka" {
  name                      = "peer2to1"
  resource_group_name       = "control_rg"
  virtual_network_name      = "control-vnet"
  remote_virtual_network_id = azurerm_virtual_network.kafka.id
}

resource "azurerm_public_ip" "example" {
  name                = "nat-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "example" {
  name                    = "nat-gateway"
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.example.id
  public_ip_address_id = azurerm_public_ip.example.id
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.kafka.id
  nat_gateway_id = azurerm_nat_gateway.example.id
}
