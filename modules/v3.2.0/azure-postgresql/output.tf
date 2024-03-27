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

output "secret_name_admin" {
  value = azurerm_key_vault_secret.datahub_psql_admin.name
}

output "secret_name_password" {
  value = azurerm_key_vault_secret.datahub_psql_password.name
}
