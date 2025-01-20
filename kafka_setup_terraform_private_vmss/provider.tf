terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}
provider "azapi" {
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  use_msi = true
}