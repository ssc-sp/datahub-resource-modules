output "psql_dns" {
  value = azurerm_postgresql_flexible_server.datahub_psql_server.fqdn
}

output "psql_id" {
  value = azurerm_postgresql_flexible_server.datahub_psql_server.id
}

output "psql_name" {
  value = azurerm_postgresql_flexible_server.datahub_psql_server.name
}

output "psql_db_name_project" {
  value = local.psql_db_name
}

