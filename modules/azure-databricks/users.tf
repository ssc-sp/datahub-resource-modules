resource "databricks_user" "datahub_dbk_user" {
  for_each = { for username in concat(var.admin_users, var.project_lead_users, var.project_users) : username.email => username }

  user_name    = each.key
  display_name = each.key
}

resource "databricks_group_member" "datahub_dbk_admin_member" {
  for_each = { for username in var.admin_users : username.email => username }

  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.datahub_dbk_user["${each.key}"].id
}

resource "databricks_group_member" "datahub_dbk_lead_member" {
  for_each = { for username in concat(var.admin_users, var.project_lead_users) : username.email => username }

  group_id  = databricks_group.project_lead.id
  member_id = databricks_user.datahub_dbk_user["${each.key}"].id
}

resource "databricks_group_member" "datahub_dbk_all_member" {
  for_each = { for username in concat(var.admin_users, var.project_lead_users, var.project_users) : username.email => username }

  group_id  = databricks_group.project_users.id
  member_id = databricks_user.datahub_dbk_user["${each.key}"].id
}
