# terraform-module-template

<!-- TODO fill in resource name in link to product documentation -->
Terraform module for [Resource name](https://example.com).

This terraform module creates a storage account with or without public access disabled.
It needs below resources to be available
1) Private dns for blob, file and other data storage for a storage account
2) Subnet for creating private endpoint
3) Containers, queues and other data storage can also be created via this module
## Example for storage account with public access disabled

```hcl
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
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sa_blob[0].id]
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

```

<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.60.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.endpoint_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.endpoint_file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.queues](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.fileshare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.tables](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_private_dns_zone.sa_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_private_dns_zone.sa_file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Specifies the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool. Changing this forces a new resource to be created. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Specifies the kind of storage account. Valid options are Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage. Changing this forces a new resource to be created. | `string` | `"StorageV2"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Specifies the Tier to use for this storage account. Valid options are Standard and Premium. Changing this forces a new resource to be created. | `string` | `"Standard"` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | List of subnet IDs allowed to access the storage account. | `list(string)` | `[]` | no |
| <a name="input_application"></a> [application](#input\_application) | Application to which the s3 bucket relates | `string` | `""` | no |
| <a name="input_attribute"></a> [attribute](#input\_attribute) | An attribute of the s3 bucket that makes it unique | `string` | `""` | no |
| <a name="input_blob_soft_delete_retention_days"></a> [blob\_soft\_delete\_retention\_days](#input\_blob\_soft\_delete\_retention\_days) | Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7` | `number` | `7` | no |
| <a name="input_change_feed_enabled"></a> [change\_feed\_enabled](#input\_change\_feed\_enabled) | Is the blob service properties for change feed events enabled? | `bool` | `false` | no |
| <a name="input_container_soft_delete_retention_days"></a> [container\_soft\_delete\_retention\_days](#input\_container\_soft\_delete\_retention\_days) | Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7` | `number` | `7` | no |
| <a name="input_containers_list"></a> [containers\_list](#input\_containers\_list) | List of containers to create and their access levels. | `list(object({ name = string, access_type = string }))` | `[]` | no |
| <a name="input_costcode"></a> [costcode](#input\_costcode) | Name of theDWP PRJ number (obtained from the project portfolio in TechNow) | `string` | `""` | no |
| <a name="input_dns_resource_group_name"></a> [dns\_resource\_group\_name](#input\_dns\_resource\_group\_name) | The name of the resource group in which DNS resides | `string` | `"RG-MDV-INT-01"` | no |
| <a name="input_enable_data_lookup"></a> [enable\_data\_lookup](#input\_enable\_data\_lookup) | n/a | `bool` | `false` | no |
| <a name="input_enable_hns"></a> [enable\_hns](#input\_enable\_hns) | Is Hierarchical Namespace enabled for this storage account? | `bool` | `false` | no |
| <a name="input_enable_large_file_share"></a> [enable\_large\_file\_share](#input\_enable\_large\_file\_share) | Is Large File Share enabled for this storage account? | `bool` | `false` | no |
| <a name="input_enable_sftp"></a> [enable\_sftp](#input\_enable\_sftp) | Is SFTP enabled for this storage account? | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Is versioning enabled? Default to `false` | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment into which resource is deployed | `string` | `""` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | List of containers to create and their access levels. | `list(object({ name = string, quota = number }))` | `[]` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Is infrastructure encryption enabled for this storage account? | `bool` | `false` | no |
| <a name="input_last_access_time_enabled"></a> [last\_access\_time\_enabled](#input\_last\_access\_time\_enabled) | Is the last access time based tracking enabled? Default to `false` | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"uksouth"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be an organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `""` | no |
| <a name="input_nfsv3_enabled"></a> [nfsv3\_enabled](#input\_nfsv3\_enabled) | Is NFSv3 protocol enabled for this storage account? | `bool` | `false` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Name of the project or sqaud within the PDU which manages the resource. May be a persons name or email also | `string` | `""` | no |
| <a name="input_private_endpoint_connection_name"></a> [private\_endpoint\_connection\_name](#input\_private\_endpoint\_connection\_name) | Endpoint connection name. | `string` | `"pvt-sa-test-conn"` | no |
| <a name="input_private_link_access"></a> [private\_link\_access](#input\_private\_link\_access) | Map of resource IDs of the private endpoints to connect to the storage account.<br>{<br>  [private\_endpoint\_id] = {<br>    endpoint\_resource\_id = [resource\_id]<br>    endpoint\_tenant\_id  = (optional) [tenant\_id]<br>  }<br>} | <pre>map(object({<br>    endpoint_resource_id = string<br>    endpoint_tenant_id   = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the public network access is enabled | `bool` | n/a | yes |
| <a name="input_queues"></a> [queues](#input\_queues) | List of storages queues | `list(string)` | `[]` | no |
| <a name="input_replication_type"></a> [replication\_type](#input\_replication\_type) | Specifies what replication applies to this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS. Changing this forces a new resource to be created. | `string` | `"LRS"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the storage account. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Is shared access key enabled for this storage account? | `bool` | `true` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_subnet_sa"></a> [subnet\_sa](#input\_subnet\_sa) | The subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tables"></a> [tables](#input\_tables) | List of storage tables. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | Name of service type | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_containers"></a> [containers](#output\_containers) | Map of containers. |
| <a name="output_file_shares"></a> [file\_shares](#output\_file\_shares) | Map of Storage SMB file shares. |
| <a name="output_queues"></a> [queues](#output\_queues) | Map of Storage SMB file shares. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
| <a name="output_storage_account_primary_access_key"></a> [storage\_account\_primary\_access\_key](#output\_storage\_account\_primary\_access\_key) | n/a |
| <a name="output_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#output\_storage\_account\_primary\_connection\_string) | n/a |
| <a name="output_storage_account_secondary_access_key"></a> [storage\_account\_secondary\_access\_key](#output\_storage\_account\_secondary\_access\_key) | n/a |
| <a name="output_storage_account_secondary_connection_string"></a> [storage\_account\_secondary\_connection\_string](#output\_storage\_account\_secondary\_connection\_string) | n/a |
| <a name="output_tables"></a> [tables](#output\_tables) | Map of Storage SMB file shares. |
<!-- END_TF_DOCS -->

## Contributing

We use pre-commit hooks for validating the terraform format and maintaining the documentation automatically.
Install it with:

```shell
$ brew install pre-commit terraform-docs
$ pre-commit install
```

If you add a new hook make sure to run it against all files:
```shell
$ pre-commit run --all-files
```
