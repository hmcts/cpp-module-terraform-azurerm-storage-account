data "azurerm_subscription" "current" {}

module "tag_set" {
  source         = "git::https://github.com/hmcts/cpp-module-terraform-azurerm-tag-generator.git?ref=main"
  namespace      = var.namespace
  application    = var.application
  costcode       = var.costcode
  owner          = var.owner
  version_number = var.version_number
  attribute      = var.attribute
  environment    = var.environment
  type           = var.type
}

resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tag_set.tags
}

resource "azurerm_virtual_network" "test" {
  name                = var.vnet_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags                = module.tag_set.tags
}

resource "azurerm_subnet" "test" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_lb" "test" {
  name                = "example-lb"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name      = "example-frontend"
    subnet_id = azurerm_subnet.test.id
  }
}

resource "azurerm_private_link_service" "test" {
  name                                        = var.private_link_service_name
  location                                    = azurerm_resource_group.test.location
  resource_group_name                         = azurerm_resource_group.test.name
  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.test.frontend_ip_configuration.0.id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address         = "10.0.1.17"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.test.id
    primary                    = true
  }
}

#resource "azurerm_private_dns_zone" "sa_blob" {
#  name                = "privatelink.blob.core.windows.net"
#  resource_group_name = azurerm_resource_group.test.name
#
#}



resource "azurerm_private_endpoint" "test" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id

  private_service_connection {
    name                           = var.private_endpoint_connection_name
    private_connection_resource_id = azurerm_private_link_service.test.id
    is_manual_connection           = false
  }
  tags = module.tag_set.tags
}

module "storage_account" {
  source                               = "../"
  storage_account_name                 = var.storage_account_name
  resource_group_name                  = azurerm_resource_group.test.name
  blob_soft_delete_retention_days      = var.blob_soft_delete_retention_days
  container_soft_delete_retention_days = var.container_soft_delete_retention_days
  public_network_access_enabled        = var.public_network_access_enabled


  private_link_access = {
    private_endpoint_1 = {
      endpoint_resource_id = azurerm_private_endpoint.test.id
    }
  }

  tags = module.tag_set.tags
}
