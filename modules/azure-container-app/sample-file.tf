resource "azurerm_storage_blob" "datahub_sample_blob" {
  name                   = "sample/nginx.conf"
  storage_account_name   = var.storage_acct_name
  storage_container_name = azurerm_storage_container.blob_container_app.name
  type                   = "Block"
  source                 = "${path.module}/sample-nginx.conf"
}
