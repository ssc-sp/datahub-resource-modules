resource "azurerm_storage_account" "datahub_storageaccount" {
  name                     = local.storage_account_name
  location                 = local.resource_group_location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  identity {
    type = "SystemAssigned"
  }

  blob_properties {
    last_access_time_enabled = "true"
  }

  tags = merge(
    var.common_tags,
    { "environment_name" : var.environment_name }
  )

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_container" "datahub_default" {
  name                  = "datahub"
  storage_account_name  = azurerm_storage_account.datahub_storageaccount.name
  container_access_type = "private"
}

