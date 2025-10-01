
resource "azurerm_storage_share" "file_share_app" {
  name                 = local.datahub_app_fileshare
  storage_account_name = var.storage_acct_name
  quota                = 128
}

resource "azurerm_container_app_environment_storage" "datahub_app" {
  name                         = azurerm_storage_share.file_share_app.name
  container_app_environment_id = azurerm_container_app_environment.proj_container_webapp_env.id
  share_name                   = local.datahub_app_fileshare
  access_mode                  = "ReadWrite"
  access_key                   = data.azurerm_key_vault_secret.storage_key_secret.value
  account_name                 = var.storage_acct_name
}
