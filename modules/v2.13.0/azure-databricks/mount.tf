resource "databricks_mount" "proj_main_mount" {
  name       = "fsdh-dbk-main-mount"
  cluster_id = databricks_cluster.dbk_proj_cluster.id

  uri = local.abfss_uri
  extra_configs = {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}",
  }
}

resource "databricks_notebook" "fsdh_sample_notebook" {
  content_base64 = base64encode(<<-EOT
      # Databricks notebook source
      # MAGIC %md
      # MAGIC # FSDH Databricks Sample
      # MAGIC This notebook is work in progress.
      # MAGIC
      # MAGIC ##How to connect to your storage

      # COMMAND ----------

      display(spark.range(10))      

      # COMMAND ----------

      # option 1. directly read a file
      abfss = spark.conf.get('abfss_uri')
      dbutils.fs.ls(abfss)
      df = spark.read.option("header","true").csv(abfss + '/fsdh-sample.csv')
      df.show(3);

      # COMMAND ----------

      # option 2. mount FSDH storage
      if any(mount.mountPoint == "/mnt/fsdh" for mount in dbutils.fs.mounts()):
              dbutils.fs.unmount("/mnt/fsdh")
      dbutils.fs.mount(
        source = spark.conf.get('wasbs_uri'),
        mount_point = "/mnt/fsdh",
        extra_configs = {'fs.azure.account.key.' + spark.conf.get('az_storage_name') +'.blob.core.windows.net':dbutils.secrets.get(scope = "datahub", key = "storage-key")})

      dbutils.fs.ls('/mnt/fsdh')
      df = spark.read.option("header","true").csv('/mnt/fsdh/fsdh-sample.csv')
      df.show(3);

    EOT
  )
  path = "/fsdh-sample"
  language = "PYTHON"
}
