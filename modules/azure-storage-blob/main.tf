resource "azurerm_storage_account" "datahub_storageaccount" {
  name                     = local.storage_account_name
  location                 = local.resource_group_location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  min_tls_version          = "TLS1_2"

  identity { type = "SystemAssigned" }

  blob_properties {
    last_access_time_enabled = "true"

    delete_retention_policy {
      days                     = 32
      permanent_delete_enabled = true
    }
    container_delete_retention_policy { days = 30 }
  }

  sas_policy { expiration_period = "3.00:00:00" }

  tags = var.project_tags

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags["created_date"]]
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

resource "azurerm_storage_share" "file_share_clamav_temp" {
  name                 = local.datahub_temp_name
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
  quota                = 128
}

resource "azurerm_storage_container" "datahub_quarantine" {
  name                  = local.datahub_quarantine
  storage_account_name  = azurerm_storage_account.datahub_storageaccount.name
  container_access_type = "private"
}
