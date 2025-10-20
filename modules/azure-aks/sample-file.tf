# resource "azurerm_storage_share_directory" "sample_dir" {
#   name             = "sample"
#   storage_share_id = azurerm_storage_share.file_share_app.id
# }

# resource "azurerm_storage_share_directory" "sample_conf_dir" {
#   name             = "sample/conf"
#   storage_share_id = azurerm_storage_share.file_share_app.id

#   depends_on = [azurerm_storage_share_directory.sample_dir]
# }

# resource "azurerm_storage_share_file" "sample_file_nginx_default" {
#   name             = "sample/conf/default.conf"
#   storage_share_id = azurerm_storage_share.file_share_app.id
#   source           = "${path.module}/sample-nginx.conf"

#   depends_on = [azurerm_storage_share_directory.sample_conf_dir]
# }
