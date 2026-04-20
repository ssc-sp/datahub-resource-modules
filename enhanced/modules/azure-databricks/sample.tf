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
