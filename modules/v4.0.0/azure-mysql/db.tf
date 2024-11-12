resource "azurerm_mysql_flexible_database" "datahub_mysql_db_default" {
  name                = local.mysql_db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
