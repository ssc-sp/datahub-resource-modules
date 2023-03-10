data "databricks_group" "admins" {
  display_name = "admins"
  depends_on   = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

data "databricks_group" "users" {
  display_name = "users"
  depends_on   = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

resource "databricks_group" "project_users" {
  display_name               = "project_users"
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

resource "databricks_group" "project_lead" {
  display_name               = "project_lead"
  allow_cluster_create       = false
  allow_instance_pool_create = true
  databricks_sql_access      = true
  workspace_access           = true

  depends_on = [azurerm_databricks_workspace.datahub_databricks_workspace]
}
