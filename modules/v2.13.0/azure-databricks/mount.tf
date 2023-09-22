resource "databricks_mount" "proj_main_mount" {
  name       = "fsdh-dbk-main-mount"
  cluster_id = databricks_cluster.dbk_proj_cluster.id

  uri = "abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net"
  extra_configs = {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}",
  }
}