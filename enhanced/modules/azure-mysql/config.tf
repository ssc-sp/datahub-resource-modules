resource "azurerm_mysql_flexible_server_configuration" "mysql_timeout" {
  name                = "interactive_timeout"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  value               = "600"
}
