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
  public_network_access_enabled     = var.public_network_access_enabled
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
}


data "azurerm_private_dns_zone" "sa_blob" {
  count               = var.enable_data_lookup ? length(var.blob_resource_group_name) : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.blob_resource_group_name[count.index]

}

data "azurerm_private_dns_zone" "sa_file" {
  count               = var.enable_data_lookup ? 1 : 0
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.dns_resource_group_name

}

resource "azurerm_private_endpoint" "endpoint_blob" {
  count               = var.public_network_access_enabled ? 0 : length(var.subnet_sa)
  name                = "${var.storage_account_name}-blob-pvt-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_sa[count.index]

  private_service_connection {
    name                           = "${var.private_endpoint_connection_name}-blob-${count.index}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-group-sa-blob-${count.index}"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sa_blob[count.index].id]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "endpoint_file" {
  count               = var.public_network_access_enabled ? 0 : length(var.subnet_sa)
  name                = "${var.storage_account_name}-file-pvt-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_sa[count.index]

  private_service_connection {
    name                           = "${var.private_endpoint_connection_name}-file-${count.index}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-group-sa-file-${count.index}"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sa_file[0].id]
  }
  tags = var.tags
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

/* This is already applied with azurerm_storage_account
resource "azurerm_storage_account_network_rules" "netrules" {
  count                      = var.public_network_access_enabled ? 0 : 1
  storage_account_id         = azurerm_storage_account.main.id
  default_action             = "Deny"
  virtual_network_subnet_ids = [var.subnet_sa]
  bypass                     = ["AzureServices"]

}
*/
