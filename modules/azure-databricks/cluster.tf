data "databricks_node_type" "dbk_smallest" {
  local_disk = true
}

data "databricks_spark_version" "dbk_latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "dbk_proj_cluster" {
  cluster_name            = "main_cluster"
  spark_version           = data.databricks_spark_version.dbk_latest_lts.id
  node_type_id            = data.databricks_node_type.dbk_smallest.id
  autotermination_minutes = 10
  num_workers             = 1

  spark_conf = {
    "spark.databricks.cluster.profile" : "serverless",
    "spark.databricks.repl.allowedLanguages" : "python,sql",
    "spark.databricks.passthrough.enabled" : "true",
    "spark.databricks.pyspark.enableProcessIsolation" : "true"
  }

  autoscale {
    min_workers = 1
    max_workers = 8
  }
}
