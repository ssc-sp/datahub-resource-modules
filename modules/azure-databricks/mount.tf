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

resource "databricks_notebook" "fsdh_sample_notebook" {
  content_base64 = local.sample_notebook_data
  path           = "/fsdh-sample"
  language       = "PYTHON"

  lifecycle {
    ignore_changes = [content_base64]
  }
}
