resource "databricks_mount" "proj_main_mount" {
  name       = "fsdh-dbk-main-mount"
  cluster_id = databricks_cluster.dbk_proj_cluster.id

  uri = local.abfss_uri
  extra_configs = {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}",
  }

  depends_on = [azurerm_key_vault_access_policy.kv_databricks_policy]
}

resource "databricks_mount" "proj_ml_mount" {
  count = var.enable_ml_cluster ? 1 : 0

  name       = "fsdh"
  cluster_id = databricks_cluster.dbk_proj_cluster_ml[count.index].id

  uri = local.abfss_uri
  extra_configs = {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}",
  }

  depends_on = [azurerm_key_vault_access_policy.kv_databricks_policy]
}

resource "databricks_mount" "proj_ml_gpu_mount" {
  count = var.enable_ml_gpu_cluster ? 1 : 0

  name       = "fsdh"
  cluster_id = databricks_cluster.dbk_proj_cluster_ml_gpu[count.index].id

  uri = local.abfss_uri
  extra_configs = {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}",
  }

  depends_on = [azurerm_key_vault_access_policy.kv_databricks_policy]
}

resource "databricks_notebook" "fsdh_sample_notebook_py" {
  path           = "/fsdh-sample-python"
  content_base64 = data.http.sample_databricks_notebook_python.response_body_base64
  language       = "PYTHON"

  lifecycle {
    ignore_changes = [content_base64]
  }
}

resource "databricks_notebook" "fsdh_sample_notebook_r" {
  content_base64 = data.http.sample_databricks_notebook_r.response_body_base64
  path           = "/fsdh-sample-r"
  language       = "R"

  lifecycle {
    ignore_changes = [content_base64]
  }
}

resource "databricks_notebook" "fsdh_sample_notebook_sql" {
  content_base64 = data.http.sample_databricks_notebook_sql.response_body_base64
  path           = "/fsdh-sample-sql"
  language       = "SQL"

  lifecycle {
    ignore_changes = [content_base64]
  }
}

resource "databricks_notebook" "fsdh_sample_notebook_serverless" {
  path = "/fsdh-sample-serverless"
  content_base64 = base64encode(<<-EOT
    # Read a sample dataset and display the first few rows
    df = spark.read.table("samples.nyctaxi.trips")
    display(df)
    df = spark.read.format("csv").option("header", "true").load("abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net/fsdh-sample.csv")
    display(df)
  EOT
  )

  language = "PYTHON"

  lifecycle {
    ignore_changes = [content_base64]
  }
}
