data "databricks_group" "admins" {
  display_name = "admins"
  depends_on   = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

resource "databricks_user" "datahub_dbk_admin_user" {
  for_each = { for username in var.admin_users : username.email => username }

  user_name    = each.key
  display_name = each.key
}

resource "databricks_group_member" "datahub_dbk_admin_member" {
  for_each = { for username in var.admin_users : username.email => username }

  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.datahub_dbk_admin_user["${each.key}"].id
}
