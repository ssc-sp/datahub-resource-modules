resource "azurerm_container_app_environment_storage" "datahub_temp" {
  name                         = local.datahub_temp_name
  container_app_environment_id = azurerm_container_app_environment.proj_container_app_env.id
  share_name                   = azurerm_storage_share.file_share_clamav_temp.name
  access_mode                  = "ReadWrite"
  access_key                   = azurerm_storage_account.datahub_storageaccount.primary_access_key
  account_name                 = azurerm_storage_account.datahub_storageaccount.name
}
