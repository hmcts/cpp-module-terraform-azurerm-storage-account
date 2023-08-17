output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_account_primary_access_key" {
  value = azurerm_storage_account.main.primary_access_key
}

output "storage_account_primary_connection_string" {
  value = azurerm_storage_account.main.primary_connection_string
}

output "storage_account_secondary_access_key" {
  value = azurerm_storage_account.main.secondary_access_key
}

output "storage_account_secondary_connection_string" {
  value = azurerm_storage_account.main.secondary_connection_string
}
