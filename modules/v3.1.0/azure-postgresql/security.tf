resource "azurerm_key_vault_secret" "datahub_psql_password" {
  name         = "datahub-psql-password"
  value        = random_password.datahub_psql_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "datahub_psql_admin" {
  name         = "datahub-psql-admin"
  value        = local.psql_admin_user
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "datahub_psql_server" {
  name         = "datahub-psql-server"
  value        = azurerm_postgresql_flexible_server.datahub_psql_server.fqdn
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_access_policy" "psql_akv_policy" {
  key_vault_id       = var.key_vault_id
  tenant_id          = var.az_tenant_id
  object_id          = azurerm_user_assigned_identity.datahub_psql_uami.principal_id
  secret_permissions = ["Get"]
  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "datahub_psql_firewall_range" {
  count = var.allow_source_ip_start == "" ? 0 : 1

  name             = "fsdh-psql-ip-range"
  server_id        = azurerm_postgresql_flexible_server.datahub_psql_server.id
  start_ip_address = var.allow_source_ip_start
  end_ip_address   = var.allow_source_ip_end == "" ? var.allow_source_ip_start : var.allow_source_ip_end
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "datahub_psql_firewall_creator" {
  name             = "fsdh-psql-ip-creator"
  server_id        = azurerm_postgresql_flexible_server.datahub_psql_server.id
  start_ip_address = data.http.myip.response_body
  end_ip_address   = data.http.myip.response_body
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "psql_dba_group_admin" {
  count = var.psql_dba_group_oid == "" ? 0 : 1

  server_name         = azurerm_postgresql_flexible_server.datahub_psql_server.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.az_tenant_id
  object_id           = var.psql_dba_group_name
  principal_name      = var.psql_dba_group_oid
  principal_type      = "Group"
}

# resource "azurerm_postgresql_flexible_server_firewall_rule" "datahub_psql_firewall_list" {
#   for_each = concat(var.allow_source_ip_list, [data.http.myip.response_body])

#   name                = "fsdh-psql-ip-list"
#   server_id           = azurerm_postgresql_flexible_server.datahub_psql_server.id
#   start_ip_address    = each.key
#   end_ip_address      = each.key
# }
