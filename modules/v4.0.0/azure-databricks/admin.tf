resource "databricks_user" "datahub_dbr_admin_users" {
  for_each = { for username in concat(var.admin_users) : username.email => username }

  user_name    = each.key
  display_name = each.key
}

resource "databricks_group_member" "datahub_dbr_admin_member" {
  for_each = { for username in var.admin_users : username.email => username }

  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.datahub_dbr_admin_users["${each.key}"].id
}
