resource "azurerm_key_vault_secret" "datahub_mysql_password" {
  name         = "datahub-mysql-password"
  value        = random_password.datahub_mysql_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "datahub_mysql_admin" {
  name         = "datahub-mysql-admin"
  value        = local.mysql_admin_user
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "datahub_mysql_server" {
  name         = "datahub-mysql-server"
  value        = azurerm_mysql_flexible_server.datahub_mysql_server.fqdn
  key_vault_id = var.key_vault_id
}

resource "azurerm_role_assignment" "kv_mysql_role_secret" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.datahub_mysql_uami.principal_id
}

resource "azurerm_role_assignment" "kv_mysql_role_crypto" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.datahub_mysql_uami.principal_id
}

resource "azurerm_mysql_flexible_server_firewall_rule" "datahub_mysql_firewall_range" {
  count = var.allow_source_ip_start == "" ? 0 : 1

  name                = "fsdh-mysql-ip-range"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  start_ip_address    = var.allow_source_ip_start
  end_ip_address      = var.allow_source_ip_end == "" ? var.allow_source_ip_start : var.allow_source_ip_end
}

resource "azurerm_mysql_flexible_server_firewall_rule" "datahub_mysql_firewall_creator" {
  name                = "fsdh-mysql-ip-creator"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  start_ip_address    = data.http.myip.response_body
  end_ip_address      = data.http.myip.response_body
}

resource "azurerm_mysql_flexible_server_active_directory_administrator" "mysql_dba_group_admin" {
  count = var.mysql_dba_group_oid == "" ? 0 : 1

  server_id   = azurerm_mysql_flexible_server.datahub_mysql_server.id
  identity_id = var.mysql_dba_group_identity
  login       = var.mysql_dba_group_name
  object_id   = var.mysql_dba_group_oid
  tenant_id   = var.az_tenant_id
}

# resource "azurerm_mysql_flexible_server_firewall_rule" "datahub_mysql_firewall_list" {
#   for_each = concat(var.allow_source_ip_list, [data.http.myip.response_body])

#   name                = "fsdh-mysql-ip-list"
#   resource_group_name = var.resource_group_name
#   server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
#   start_ip_address    = each.key
#   end_ip_address      = each.key
# }
