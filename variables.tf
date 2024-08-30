variable "location" {
  type    = string
  default = "uksouth"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be an organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "costcode" {
  type        = string
  description = "Name of theDWP PRJ number (obtained from the project portfolio in TechNow)"
  default     = ""
}

variable "owner" {
  type        = string
  description = "Name of the project or sqaud within the PDU which manages the resource. May be a persons name or email also"
  default     = ""
}


variable "application" {
  type        = string
  description = "Application to which the s3 bucket relates"
  default     = ""
}

variable "attribute" {
  type        = string
  description = "An attribute of the s3 bucket that makes it unique"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment into which resource is deployed"
  default     = ""
}

variable "type" {
  type        = string
  description = "Name of service type"
  default     = ""
}

variable "storage_account_name" {
  description = "The name of the storage account. Changing this forces a new resource to be created."
  type        = string
  default     = null
  validation {
    condition     = length(var.storage_account_name) >= 3 && substr(var.storage_account_name, 0, 2) == "sa"
    error_message = "The storage account name should start with 'sa' and be at least 3 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  type        = string
}

variable "account_kind" {
  description = "Specifies the kind of storage account. Valid options are Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage. Changing this forces a new resource to be created."
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "Specifies the Tier to use for this storage account. Valid options are Standard and Premium. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Specifies what replication applies to this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS. Changing this forces a new resource to be created."
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Specifies the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool. Changing this forces a new resource to be created."
  type        = string
  default     = "Hot"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "enable_hns" {
  description = "Is Hierarchical Namespace enabled for this storage account?"
  type        = bool
  default     = false
}

variable "enable_sftp" {
  description = "Is SFTP enabled for this storage account?"
  type        = bool
  default     = false
}

variable "enable_large_file_share" {
  description = "Is Large File Share enabled for this storage account?"
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled for this storage account?"
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled for this storage account?"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Is shared access key enabled for this storage account?"
  type        = bool
  default     = true
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the storage account."
  type        = list(string)
  default     = []
}

variable "private_link_access" {
  description = <<-EOF
  Map of resource IDs of the private endpoints to connect to the storage account.
  {
    [private_endpoint_id] = {
      endpoint_resource_id = [resource_id]
      endpoint_tenant_id  = (optional) [tenant_id]
    }
  }
EOF

  type = map(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = optional(string)
  }))

  default = {}
}

variable "blob_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
  type        = number
}

variable "container_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
  type        = number
}

variable "enable_versioning" {
  description = "Is versioning enabled? Default to `false`"
  default     = false
  type        = bool
}
variable "last_access_time_enabled" {
  description = "Is the last access time based tracking enabled? Default to `false`"
  default     = false
  type        = bool
}
variable "change_feed_enabled" {
  description = "Is the blob service properties for change feed events enabled?"
  default     = false
  type        = bool
}

variable "containers_list" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, access_type = string }))
  default     = []
}

variable "file_shares" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, quota = number }))
  default     = []
}

variable "queues" {
  description = "List of storages queues"
  type        = list(string)
  default     = []
}

variable "tables" {
  description = "List of storage tables."
  type        = list(string)
  default     = []
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled"
  type        = bool
}

variable "dns_resource_group_name_list" {
  description = "private_dns"
  type        = list(string)
  default     = []
}

variable "dns_resource_group_name" {
  description = "private_dns"
  type        = string
  default     = "RG-MDV-INT-01"
}

variable "enable_lifecycle_policy" {
  description = "Enable or disable lifecycle policy"
  type        = bool
  default     = false
}

variable "lifecycle_policy_rule" {
  description = "Lifecycle policy rule to be applied"
  type = object({
    name         = string
    enabled      = bool
    days         = number
    prefix_match = optional(list(string))
    blob_types   = list(string)
  })
  default = null
}

variable "private_endpoints_config_blob" {
  description = "Configuration for the private endpoints"
  type        = list(any)
  default     = []
}

variable "private_endpoints_config_file" {
  description = "Configuration for the private endpoints"
  type        = list(any)
  default     = []
}

variable "private_endpoints_config_dfs" {
  description = "Configuration for the private endpoints"
  type        = list(any)
  default     = []
}

variable "network_rules" {
  description = "Network rules"
  type = object({
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
    bypass                     = optional(list(string))
  })
  default = null
}

variable "role_assignments" {
  description = "List of Role Assignments to create, scoped to this storage account"
  type = list(object({
    role_name = string // Name of the RBAC role to assign
    object_id = string // principal (object) id to assign the role to
  }))
  default = []
}
