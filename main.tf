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

resource "azurerm_storage_management_policy" "main" {
  count              = var.enable_lifecycle_policy && var.lifecycle_policy_rule != {} ? 1 : 0
  storage_account_id = azurerm_storage_account.main.id
  rule {
    name    = var.lifecycle_policy_rule.name
    enabled = var.lifecycle_policy_rule.enabled
    filters {
      prefix_match = var.lifecycle_policy_rule.prefix_match
      blob_types   = var.lifecycle_policy_rule.blob_types
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.lifecycle_policy_rule.days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.lifecycle_policy_rule.days
      }
    }
  }
}

resource "azurerm_private_endpoint" "endpoint_blob" {
  for_each            = { for i, config in var.private_endpoints_config_blob : i => config }
  name                = "blob-pe-${each.value.subnet_name}-${azurerm_storage_account.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "blob-psc-${each.value.subnet_name}-${azurerm_storage_account.main.name}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-grp-blob-${each.value.private_dns_resource_group_name}"
    private_dns_zone_ids = [each.value.dns_id]
  }
  tags = var.tags

  provisioner "local-exec" {
    command = "sleep ${local.post_private_endpoint_sleep_duration}"
  }
}

resource "azurerm_private_endpoint" "endpoint_file" {
  for_each            = { for i, config in var.private_endpoints_config_file : i => config }
  name                = "file-pe-${each.value.subnet_name}-${azurerm_storage_account.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "file-psc-${each.value.subnet_name}-${azurerm_storage_account.main.name}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-group-file-${each.value.private_dns_resource_group_name}"
    private_dns_zone_ids = [each.value.dns_id]
  }
  tags = var.tags

  provisioner "local-exec" {
    command = "sleep ${local.post_private_endpoint_sleep_duration}"
  }
}

resource "azurerm_private_endpoint" "endpoint_dfs" {
  for_each            = { for i, config in var.private_endpoints_config_dfs : i => config }
  name                = "dfs-pe-${each.value.subnet_name}-${azurerm_storage_account.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "dfs-psc-${each.value.subnet_name}-${azurerm_storage_account.main.name}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-group-dfs-${each.value.private_dns_resource_group_name}"
    private_dns_zone_ids = [each.value.dns_id]
  }
  tags = var.tags

  provisioner "local-exec" {
    command = "sleep ${local.post_private_endpoint_sleep_duration}"
  }
}

resource "azurerm_storage_container" "container" {
  count                 = var.containers_list == null ? 0 : length(var.containers_list)
  name                  = var.containers_list[count.index].name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.containers_list[count.index].access_type
  depends_on = [
    azurerm_private_endpoint.endpoint_blob,
    azurerm_private_endpoint.endpoint_file
  ]
}


resource "azurerm_storage_share" "fileshare" {
  count                = var.file_shares == null ? 0 : length(var.file_shares)
  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.main.name
  quota                = var.file_shares[count.index].quota
  depends_on = [
    azurerm_private_endpoint.endpoint_blob,
    azurerm_private_endpoint.endpoint_file
  ]
}

resource "azurerm_storage_table" "tables" {
  count                = var.tables == null ? 0 : length(var.tables)
  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.main.name
  depends_on = [
    azurerm_private_endpoint.endpoint_blob,
    azurerm_private_endpoint.endpoint_file
  ]
}

resource "azurerm_storage_queue" "queues" {
  count                = var.queues == null ? 0 : length(var.queues)
  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.main.name
  depends_on = [
    azurerm_private_endpoint.endpoint_blob,
    azurerm_private_endpoint.endpoint_file
  ]
}

resource "azurerm_storage_account_network_rules" "main" {
  count                      = var.network_rules == null ? 0 : 1
  storage_account_id         = azurerm_storage_account.main.id
  default_action             = var.network_rules.default_action
  ip_rules                   = var.network_rules.ip_rules
  virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
  bypass                     = try(var.network_rules.bypass, null)
}

resource "azurerm_role_assignment" "this" {
  for_each             = toset(var.role_assignments)
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
  scope                = azurerm_storage_account.main.id
}

resource "vault_generic_secret" "administrator_creds" {
  count = var.create_access_key_in_vault ? 1 : 0
  path  = "secret/${var.environment}/${var.storage_account_name}"

  data_json = <<EOT
{
  "connection_string": "${azurerm_storage_account.main.primary_connection_string}"
}
EOT
}

locals {
  container_name_to_index = {
    for idx, container in var.containers_list : container.name => idx
  }
}

resource "azurerm_role_assignment" "container_roles" {
  for_each = {
    for idx, container in var.containers_list :
    "${idx}-${container.name}" => container
    if length(container.role_assignments) > 0
  }

  scope                = azurerm_storage_container.container[local.container_name_to_index[each.value.name]].resource_manager_id
  role_definition_name = each.value.role_assignments[0].role_name
  principal_id         = each.value.role_assignments[0].object_id
}

resource "azurerm_management_lock" "storage_account_lock" {
  name       = "lock-${azurerm_storage_account.main.name}"
  scope      = azurerm_storage_account.main.id
  lock_level = "CanNotDelete"
  notes      = "This lock protects the storage account from accidental deletion."
}
