resource "azurerm_storage_share" "file_share_app" {
  name                 = "app"
  storage_account_name = var.storage_acct_name
  quota                = 64
}

resource "azurerm_storage_container" "blob_container_app" {
  name                  = "app"
  storage_account_name  = var.storage_acct_name
  container_access_type = "private"
}

