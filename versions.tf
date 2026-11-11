terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # azurerm 5.x removed storage_account_name on azurerm_storage_container (and
      # other v3-style arguments this module uses). Callers pin 3.x (storage account
      # repo) and 4.x (azure-backup-vault).
      version = ">= 3.103.1, < 5.0.0"
    }
  }
}
