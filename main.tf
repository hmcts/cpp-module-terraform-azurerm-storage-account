resource "azurerm_storage_account" "main" {
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  account_replication_type          = var.replication_type
  access_tier                       = var.access_tier
  is_hns_enabled                    = var.enable_hns
  sftp_enabled                      = var.enable_sftp
  large_file_share_enabled          = var.enable_large_file_share
  allow_nested_items_to_be_public   = false
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  nfsv3_enabled                     = var.nfsv3_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  tags                              = var.tags

  identity {
    type = "SystemAssigned"
  }

  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
    versioning_enabled       = var.enable_versioning
    last_access_time_enabled = var.last_access_time_enabled
    change_feed_enabled      = var.change_feed_enabled
  }

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = var.allowed_subnet_ids
    bypass                     = ["None"]

    dynamic "private_link_access" {
      for_each = var.private_link_access == null ? {} : var.private_link_access

      content {
        endpoint_resource_id = lookup(private_link_access.value, "endpoint_resource_id")
        endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
      }
    }
  }
}

resource "azurerm_storage_container" "container" {
  count                 = var.containers_list == null ? 0 : length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.containers_list[count.index].access_type
}

resource "azurerm_storage_share" "fileshare" {
  count                = var.file_shares == null ? 0 : length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.main.name
  quota                = var.file_shares[count.index].quota
}

resource "azurerm_storage_table" "tables" {
  count                = var.tables == null ? 0 : length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_queue" "queues" {
  count                = var.queues == null ? 0 : length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.main.name
}
