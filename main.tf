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

  #  network_rules {
  #    default_action             = "Deny"
  #    virtual_network_subnet_ids = var.allowed_subnet_ids
  #    bypass                     = ["None"]
  #
  #    dynamic "private_link_access" {
  #     for_each = var.public_network_access_enabled !=null ? ["sa"] : []
  #
  #      content {
  #        endpoint_resource_id = azurerm_private_endpoint.test[0].id
  #
  ##        endpoint_resource_id = lookup(private_link_access.value, "endpoint_resource_id")
  ##        endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
  #      }
  #    }
  #  }
}




resource "azurerm_private_endpoint" "test" {
  for_each            = { for k, v in var.resources : k => v if var.public_network_access_enabled != null }
  name                = format("%s-%s", lookup(each.value, "resource_name"), lookup(each.value, "resource_type"))
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_sa

  private_service_connection {
    name                           = var.private_endpoint_connection_name
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = [lookup(each.value, "resource_type")]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-group-sa"
    private_dns_zone_ids = [lookup(each.value, "private_dns_zone_id")]
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

resource "azurerm_storage_account_network_rules" "netrules" {
  storage_account_id         = azurerm_storage_account.main.id
  default_action             = "Deny"
  virtual_network_subnet_ids = [var.subnet_sa]
  bypass                     = ["AzureServices"]

  dynamic "private_link_access" {
    for_each = azurerm_private_endpoint.test

    content {
      endpoint_resource_id = private_link_access.value.id

      #        endpoint_resource_id = lookup(private_link_access.value, "endpoint_resource_id")
      #        endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
    }
  }

}
