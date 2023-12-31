terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.90.0"
    }
  }
  
  backend "azurerm" {
    subscription_id      = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    tenant_id            = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    key                  = "main.terraform.tfstate"
    storage_account_name = "stname"
    container_name       = "containername"
    access_key           = "base64code=="
  }
  
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription-id
}
