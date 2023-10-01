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

resource "azurerm_key_vault_secret" "datahub_mysql_connection_str" {
  name         = "datahub-mysql-conn"
  value        = "Server=${local.mysql_server_name};Database=${local.mysql_db_name};Uid=${local.mysql_admin_user};Pwd=${random_password.datahub_mysql_password.result};"
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_access_policy" "mysql_akv_policy" {
  key_vault_id       = var.key_vault_id
  tenant_id          = var.az_tenant_id
  object_id          = azurerm_user_assigned_identity.datahub_mysql_uami.id
  secret_permissions = ["Get"]
}

resource "azurerm_mysql_server_key" "mysql_cmk_link" {
  server_id        = azurerm_mysql_flexible_server.datahub_mysql_server.id
  key_vault_key_id = var.key_vault_cmk_id

  depends_on = [azurerm_key_vault_access_policy.mysql_akv_policy]
}

resource "azurerm_mysql_firewall_rule" "datahub_mysql_firewall_creator" {
  name                = "fsdh-mysql-creator-rule"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  start_ip_address    = data.http.myip.response_body
  end_ip_address      = data.http.myip.response_body
}

resource "azurerm_mysql_firewall_rule" "datahub_mysql_firewall_range" {
  count = var.allow_source_ip_start == "" ? 0 : 1

  name                = "fsdh-mysql-ip-range"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  start_ip_address    = var.allow_source_ip_start
  end_ip_address      = var.allow_source_ip_end == "" ? var.allow_source_ip_start : var.allow_source_ip_end
}

resource "azurerm_mysql_firewall_rule" "datahub_mysql_firewall_list" {
  for_each = var.allow_source_ip_list

  name                = "fsdh-mysql-ip-list"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.datahub_mysql_server.name
  start_ip_address    = each.key
  end_ip_address      = each.key
}
