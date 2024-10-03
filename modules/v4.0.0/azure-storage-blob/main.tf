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
    change_feed_enabled      = "true"

    delete_retention_policy {
      days                     = 32
      permanent_delete_enabled = true
    }
    restore_policy { days = 30 }
    container_delete_retention_policy { days = 30 }
  }

  tags = local.project_tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_container" "datahub_default" {
  name                  = local.datahub_mount_name
  storage_account_name  = azurerm_storage_account.datahub_storageaccount.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_backup" {
  name                  = local.datahub_backup_name
  storage_account_name  = azurerm_storage_account.datahub_storageaccount.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_log" {
  name                  = local.datahub_log_name
  storage_account_name  = azurerm_storage_account.datahub_storageaccount.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "file_share_default" {
  name                 = local.datahub_mount_name
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
  quota                = 64
}

