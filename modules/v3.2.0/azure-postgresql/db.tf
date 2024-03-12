resource "azurerm_postgresql_flexible_server_database" "datahub_psql_db_default" {
  name      = local.psql_db_name
  server_id = azurerm_postgresql_flexible_server.datahub_psql_server.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "null_resource" "datahub_psql_db_extension" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $env:PGPASSWORD="${random_password.datahub_psql_password.result}" 
      psql -h ${azurerm_postgresql_flexible_server.datahub_psql_server.fqdn} -U ${local.psql_admin_user} -d ${local.psql_db_name} -c "create extension postgis"
    EOT
    on_failure  = continue
  }
}
