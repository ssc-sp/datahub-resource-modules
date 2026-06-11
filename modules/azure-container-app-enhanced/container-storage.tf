
resource "azurerm_storage_share" "file_share_app" {
  name                 = local.datahub_app_fileshare
  storage_account_name = var.storage_acct_name
  quota                = 128
}

resource "azurerm_storage_share_directory" "db_dir" {
  name             = "db"
  storage_share_id = azurerm_storage_share.file_share_app.id
}

resource "azurerm_container_app_environment_storage" "datahub_app" {
  name                         = azurerm_storage_share.file_share_app.name
  container_app_environment_id = var.aca_env_id
  share_name                   = local.datahub_app_fileshare
  access_mode                  = "ReadWrite"
  access_key                   = var.storage_acct_key
  account_name                 = var.storage_acct_name
}
