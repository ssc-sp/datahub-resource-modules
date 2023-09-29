locals {
  # To make existing clusters to support R, run: terraform taint module.azure_databricks_module.databricks_cluster.dbk_proj_cluster
  # https://learn.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/clusters
  datahub_policy_regular = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 12 },
    "node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5"], "defaultValue" : "Standard_D4ds_v5" },
    "driver_node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5"], "defaultValue" : "Standard_D4ds_v5" },
    "autotermination_minutes" : { "type" : "range", "defaultValue" : 10, "minValue" : 10, "maxValue" : 60 }
    "autoscale.min_workers" : { "type" : "fixed", "value" : 0 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 4, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
    "spark_conf.fs.azure.sas.fixed.token.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "{{secrets/datahub/container-sas}}", "hidden" : true },
    "spark_conf.fs.azure.account.auth.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "SAS", "hidden" : true },
    "spark_conf.fs.azure.sas.token.provider.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "org.apache.hadoop.fs.azurebfs.sas.FixedSASTokenProvider", "hidden" : true },
  }

  datahub_policy_small = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 4 },
    "node_type_id" : { "type" : "fixed", "value" : "Standard_D4ds_v5", "hidden" : false },
    "driver_node_type_id" : { "type" : "fixed", "value" : "Standard_D4ds_v5" },
    "autotermination_minutes" : { "type" : "range", "defaultValue" : 10, "minValue" : 10, "maxValue" : 120 }
    "autoscale.min_workers" : { "type" : "fixed", "value" : 0 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 2, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
    "spark_conf.fs.azure.sas.fixed.token.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "{{secrets/datahub/container-sas}}", "hidden" : true },
    "spark_conf.fs.azure.account.auth.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "SAS", "hidden" : true },
    "spark_conf.fs.azure.sas.token.provider.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "org.apache.hadoop.fs.azurebfs.sas.FixedSASTokenProvider", "hidden" : true },
    "spark_conf.abfss_uri" : { "type" : "fixed", "value" : "${databricks_mount.proj_main_mount.uri}", "hidden" : true },
  }

  datahub_policy_large = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 64 },
    "node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5", "Standard_D48ds_v5", "Standard_D64ds_v5"], "defaultValue" : "Standard_D8ds_v5" },
    "driver_node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5", "Standard_D48ds_v5", "Standard_D64ds_v5"], "defaultValue" : "Standard_D8ds_v5" },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10 },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 0 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 32, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
    "spark_conf.fs.azure.sas.fixed.token.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "{{secrets/datahub/container-sas}}", "hidden" : true },
    "spark_conf.fs.azure.account.auth.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "SAS", "hidden" : true },
    "spark_conf.fs.azure.sas.token.provider.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "org.apache.hadoop.fs.azurebfs.sas.FixedSASTokenProvider", "hidden" : true },
    "spark_conf.abfss_uri" : { "type" : "fixed", "value" : "${databricks_mount.proj_main_mount.uri}", "hidden" : true },
  }

  datahub_policy_regular_job_spot = {
    "cluster_type" : { "type" : "fixed", "value" : "job" },
    "dbus_per_hour" : { "type" : "range", "maxValue" : 12 },
    "node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5"], "defaultValue" : "Standard_D4ds_v5" },
    "driver_node_type_id" : { "type" : "allowlist", "values" : ["Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5"], "defaultValue" : "Standard_D4ds_v5" },
    "autotermination_minutes" : { "type" : "fixed", "value" : 10 },
    "autoscale.min_workers" : { "type" : "fixed", "value" : 0 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 4, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.passthrough.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.pyspark.enableProcessIsolation" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
    "azure_attributes.first_on_demand" : { "type" : "fixed", "value" : 1 },
    "azure_attributes.availability" : { "type" : "fixed", "value" : "SPOT_WITH_FALLBACK_AZURE" },
    "azure_attributes.spot_bid_max_price" : { "type" : "fixed", "value" : -1.0 }
    "spark_conf.fs.azure.sas.fixed.token.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "{{secrets/datahub/container-sas}}", "hidden" : true },
    "spark_conf.fs.azure.account.auth.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "SAS", "hidden" : true },
    "spark_conf.fs.azure.sas.token.provider.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "org.apache.hadoop.fs.azurebfs.sas.FixedSASTokenProvider", "hidden" : true },
    "spark_conf.abfss_uri" : { "type" : "fixed", "value" : "${databricks_mount.proj_main_mount.uri}", "hidden" : true },
  }

  datahub_policy_small_docker = {
    "dbus_per_hour" : { "type" : "range", "maxValue" : 4 },
    "node_type_id" : { "type" : "fixed", "value" : "Standard_D4ds_v5", "hidden" : false },
    "driver_node_type_id" : { "type" : "fixed", "value" : "Standard_D4ds_v5" },
    "autotermination_minutes" : { "type" : "range", "defaultValue" : 10, "minValue" : 10, "maxValue" : 120 }
    "autoscale.min_workers" : { "type" : "fixed", "value" : 1 },
    "autoscale.max_workers" : { "type" : "range", "maxValue" : 8, "defaultValue" : 2 },
    "custom_tags.project_code" : { "type" : "fixed", "value" : "${var.project_cd}" },
    "custom_tags.environment" : { "type" : "fixed", "value" : "${var.environment_name}" },
    "custom_tags.project_prefix" : { "type" : "fixed", "value" : "fsdh" },
    "spark_conf.spark.databricks.delta.preview.enabled" : { "type" : "fixed", "value" : "true", "hidden" : true },
    "spark_conf.spark.databricks.repl.allowedLanguages" : { "type" : "fixed", "value" : "python,sql,r", "hidden" : true },
    "data_security_mode" : { "type" : "fixed", "value" : "NONE" },
    "runtime_engine" : { "type" : "fixed", "value" : "STANDARD" },
    "enable_local_disk_encryption" : { "type" : "fixed", "value" : true },
    "azure_attributes.first_on_demand" : { "type" : "fixed", "value" : 1 },
    "azure_attributes.availability" : { "type" : "fixed", "value" : "ON_DEMAND_AZURE" },
    "azure_attributes.spot_bid_max_price" : { "type" : "fixed", "value" : -1 },
    "spark_conf.fs.azure.sas.fixed.token.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "{{secrets/datahub/container-sas}}", "hidden" : true },
    "spark_conf.fs.azure.account.auth.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "SAS", "hidden" : true },
    "spark_conf.fs.azure.sas.token.provider.type.${var.storage_acct_name}.dfs.core.windows.net" : { "type" : "fixed", "value" : "org.apache.hadoop.fs.azurebfs.sas.FixedSASTokenProvider", "hidden" : true },
    "spark_conf.abfss_uri" : { "type" : "fixed", "value" : "${databricks_mount.proj_main_mount.uri}", "hidden" : true },
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

resource "databricks_cluster_policy" "regular_spot_cluster_policy" {
  name       = "Datahub Job Cluster (Spot Regular)"
  definition = jsonencode(local.datahub_policy_regular_job_spot)
}

resource "databricks_cluster_policy" "docker_small_cluster_policy" {
  name       = "Datahub Docker Cluster (Small)"
  definition = jsonencode(local.datahub_policy_small_docker)
}
