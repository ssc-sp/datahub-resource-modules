resource "azurerm_storage_data_lake_gen2_path" "datahub_upload_folder" {
  path               = local.upload_folder_name
  filesystem_name    = azurerm_storage_container.datahub_default.name
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
  resource           = "directory"

  depends_on = [
    azurerm_storage_container.datahub_default
  ]
}
