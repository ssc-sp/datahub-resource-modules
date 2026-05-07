output "mysql_dns" {
  value = azurerm_mysql_flexible_server.datahub_mysql_server.fqdn
}

output "mysql_id" {
  value = azurerm_mysql_flexible_server.datahub_mysql_server.id
}

output "mysql_name" {
  value = azurerm_mysql_flexible_server.datahub_mysql_server.name
}

output "mysql_db_name_project" {
  value = local.mysql_db_name
}

