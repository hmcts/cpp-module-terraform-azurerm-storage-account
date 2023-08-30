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

output "containers" {
  description = "Map of containers."
  value       = { for c in azurerm_storage_container.container : c.name => c.id }
}

output "file_shares" {
  description = "Map of Storage SMB file shares."
  value       = { for f in azurerm_storage_share.fileshare : f.name => f.id }
}

output "tables" {
  description = "Map of Storage SMB file shares."
  value       = { for t in azurerm_storage_table.tables : t.name => t.id }
}

output "queues" {
  description = "Map of Storage SMB file shares."
  value       = { for q in azurerm_storage_queue.queues : q.name => q.id }
}
