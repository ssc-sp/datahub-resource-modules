resource "azurerm_storage_account" "datahub_storageaccount" {
  name                          = local.storage_account_name
  location                      = local.resource_group_location
  resource_group_name           = azurerm_resource_group.az_project_rg.name
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  is_hns_enabled                = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true

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

  tags = local.project_tags

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags]
  }
}

resource "azurerm_storage_container" "datahub_default" {
  name                  = local.datahub_mount_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_backup" {
  name                  = local.datahub_backup_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_log" {
  name                  = local.datahub_log_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_share" "file_share_default" {
  name               = local.datahub_mount_name
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
  quota              = 64
}

resource "azurerm_storage_share" "file_share_clamav_temp" {
  name               = local.datahub_temp_name
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
  quota              = 128
}

resource "azurerm_storage_container" "datahub_quarantine" {
  name                  = local.datahub_quarantine
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_stage" {
  name                  = local.datahub_stage_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_catalog" {
  name                  = local.datahub_catalog_container
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_external_uploads" {
  name                  = local.datahub_upload_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_shared" {
  name                  = local.datahub_shared_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "datahub_users" {
  name                  = local.datahub_users_name
  storage_account_id    = azurerm_storage_account.datahub_storageaccount.id
  container_access_type = "private"
}

resource "azurerm_storage_table" "datahub_clamav_infected" {
  name               = "infectedfiles"
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
}

