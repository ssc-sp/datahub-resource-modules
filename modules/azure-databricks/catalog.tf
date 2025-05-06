resource "databricks_metastore_assignment" "fsdh_dbr_metastore_assign" {
  metastore_id = "4f349eb3-d46c-44c6-b98e-548d97a08ba3"
  workspace_id = azurerm_databricks_workspace.datahub_databricks_workspace.workspace_id
}
