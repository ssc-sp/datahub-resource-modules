resource "azurerm_storage_account" "datahub_seed_storageaccount" {
  name                     = local.seed_storage_account_name
  location                 = azurerm_resource_group.az_project_rg.location
  resource_group_name      = azurerm_resource_group.az_project_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  identity { type = "SystemAssigned" }

  blob_properties {
    last_access_time_enabled = "true"

    delete_retention_policy {
      days                     = 32
      permanent_delete_enabled = true
    }
    container_delete_retention_policy { days = 30 }
  }
}

resource "azurerm_key_vault_secret" "datahub_seed_storageaccount_str" {
  name         = local.seed_storage_secret_name
  value        = azurerm_storage_account.datahub_seed_storageaccount.primary_connection_string
  key_vault_id = azurerm_key_vault.az_proj_kv.id
}
