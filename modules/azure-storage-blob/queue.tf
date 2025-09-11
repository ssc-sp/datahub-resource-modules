resource "azurerm_storage_queue" "blob_created_event_queue" {
  name                 = local.blob_created_queue
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
}

resource "azurerm_storage_queue" "blob_job_disabled_event_queue" {
  name                 = local.blob_muted_queue
  storage_account_name = azurerm_storage_account.datahub_storageaccount.name
}

