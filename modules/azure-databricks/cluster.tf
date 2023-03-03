data "databricks_node_type" "dbk_default" {
  local_disk = true

  category = "General Purpose"


  depends_on = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

data "databricks_spark_version" "dbk_latest_lts" {
  long_term_support = true

  depends_on = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

resource "databricks_cluster" "dbk_proj_cluster" {
  cluster_name            = "main_cluster"
  spark_version           = data.databricks_spark_version.dbk_latest_lts.id
  node_type_id            = "Standard_D4s_v3"
  driver_node_type_id     = "Standard_D4s_v3"
  autotermination_minutes = 10
  num_workers             = 1
  policy_id               = databricks_cluster_policy.regular_cluster_policy.id

  spark_conf = {
    "spark.databricks.cluster.profile" : "serverless",
    "spark.databricks.repl.allowedLanguages" : "python,sql",
    "spark.databricks.passthrough.enabled" : "true",
    "spark.databricks.pyspark.enableProcessIsolation" : "true"
  }

  autoscale {
    min_workers = 1
    max_workers = 2
  }
}
