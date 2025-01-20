###################### VMSS #####################


resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "kafkazookeeper-vmss"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "azureuser"
  upgrade_mode        = "Manual"
  computer_name_prefix = "kafkazookeeperprefix"
  overprovision       = false

  source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts"
  version   = "latest"
}

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface {
    name                      = "nic-kafka"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.example.id

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.kafka.id
    }
  }
}


data "azurerm_virtual_machine_scale_set" "example" {
  name                = azurerm_linux_virtual_machine_scale_set.example.name
  resource_group_name = azurerm_resource_group.example.name
}


output "virtual_machine_ips" {
  value = data.azurerm_virtual_machine_scale_set.example.instances.*.private_ip_address
}



resource "null_resource" "launch_ansible_playbook"{
  triggers = { 
    trigger = join(",", data.azurerm_virtual_machine_scale_set.example.instances.*.private_ip_address) 
  }
  provisioner "local-exec" {
    working_dir = "../install_kafka_with_ansible_roles"
    command = "ansible-playbook -i dynamic_inventory_azure_rm.yml deploy_kafka_playbook.yaml"
}
}