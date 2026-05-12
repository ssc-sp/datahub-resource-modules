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

resource "databricks_notebook" "fsdh_sample_py_serverless" {
  path = "/fsdh-sample-serverless.py"
  content_base64 = base64encode(<<-EOT
    # Read a sample dataset and display the first few rows
    df = spark.read.table("samples.nyctaxi.trips")
    display(df)
    df = spark.read.format("csv").option("header", "true").load("abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net/fsdh-sample.csv")
    display(df)
    drop table if exists `${databricks_catalog.datahub_proj_catalog.name}`.${databricks_schema.datahub_proj_schema_bronze.name}.fsdh_sample;
    create TABLE if not exists `${databricks_catalog.datahub_proj_catalog.name}`.${databricks_schema.datahub_proj_schema_bronze.name}.fsdh_sample USING CSV OPTIONS (header = "true") LOCATION "abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net/fsdh-sample.csv";
    select * from `${databricks_catalog.datahub_proj_catalog.name}`.${databricks_schema.datahub_proj_schema_bronze.name}.fsdh_sample
  EOT
  )

  language = "PYTHON"

  lifecycle {
    ignore_changes = [content_base64]
  }
}

resource "databricks_notebook" "fsdh_sample_sql_serverless" {
  path = "/fsdh-sample-serverless.sql"
  content_base64 = base64encode(<<-EOT
    drop table if exists `${databricks_catalog.datahub_proj_catalog.name}`.${databricks_schema.datahub_proj_schema_bronze.name}.fsdh_sample;
    create TABLE if not exists `${databricks_catalog.datahub_proj_catalog.name}`.${databricks_schema.datahub_proj_schema_bronze.name}.fsdh_sample USING CSV OPTIONS (header = "true") LOCATION "abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net/fsdh-sample.csv";
    select * from `${databricks_catalog.datahub_proj_catalog.name}`.${databricks_schema.datahub_proj_schema_bronze.name}.fsdh_sample
  EOT
  )

  language = "SQL"

  lifecycle {
    ignore_changes = [content_base64]
  }
}
