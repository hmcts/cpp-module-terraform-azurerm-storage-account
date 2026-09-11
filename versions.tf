terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 2.21.0"
    }
  }
}
