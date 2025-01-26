
data "http" "myip" {
  url = "https://ipinfo.io/ip" # https://ipv4.icanhazip.com
}


resource "azurerm_key_vault" "example" {
  name                       = "control-keyvault"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    ip_rules = ["${chomp(data.http.myip.response_body)}"]
    virtual_network_subnet_ids = [azurerm_subnet.control.id]
  }
}


resource "azurerm_role_assignment" "keyvault" {
  scope              = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id       = azurerm_linux_virtual_machine.example.identity[0].principal_id
}


resource "azurerm_key_vault_secret" "example" {
  name         = "github-token"
  value        = var.github_token
  key_vault_id = azurerm_key_vault.example.id
  depends_on = [azurerm_role_assignment.user]
}





