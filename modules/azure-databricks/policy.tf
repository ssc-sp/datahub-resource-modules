locals {
  datahub_policy_regular = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 12 },
    "node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5"], "defaultValue" : "Standard_D4ds_v5" },
    "driver_node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5"], "defaultValue" : "Standard_D4ds_v5" },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10 },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 4, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.cluster.profile" : { "type" : "fixed", "value" : "serverless", "hidden" : true },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
  }

  datahub_policy_small = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 4 },
    "node_type_id" : { "type" : "fixed", "value" : "Standard_D4ds_v5", "hidden" : false },
    "driver_node_type_id" : { "type" : "fixed", "value" : "Standard_D4ds_v5" },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10 },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 2, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.cluster.profile" : { "type" : "fixed", "value" : "serverless", "hidden" : true },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
  }

  datahub_policy_large = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 64 },
    "node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5", "Standard_D48ds_v5", "Standard_D64ds_v5"], "defaultValue" : "Standard_D8ds_v5" },
    "driver_node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5", "Standard_D48ds_v5", "Standard_D64ds_v5"], "defaultValue" : "Standard_D8ds_v5" },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10 },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 32, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.cluster.profile" : { "type" : "fixed", "value" : "serverless", "hidden" : true },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
  }

  datahub_policy_overrides = {
    description = "Datahub Cluster policy overrides"
  }
}

resource "databricks_cluster_policy" "regular_cluster_policy" {
  name       = "Datahub Regular Cluster"
  definition = jsonencode(local.datahub_policy_regular)
}

resource "databricks_cluster_policy" "small_cluster_policy" {
  name       = "Datahub Small Cluster"
  definition = jsonencode(local.datahub_policy_small)
}

resource "databricks_cluster_policy" "large_cluster_policy" {
  name       = "Datahub Large Cluster"
  definition = jsonencode(local.datahub_policy_large)
}
