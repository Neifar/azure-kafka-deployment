data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "example" {
  name                       = "control-keyvault"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "example" {
  name         = "github-token"
  value        = "secret1"
  key_vault_id = azurerm_key_vault.example.id
}


resource "azurerm_role_assignment" "keyvault" {
  scope              = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id       = azurerm_linux_virtual_machine.example.identity[0].principal_id
}