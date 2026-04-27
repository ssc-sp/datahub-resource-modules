data "databricks_node_type" "dbk_default" {
  local_disk = true

  category = "General Purpose"


  depends_on = [azapi_resource.fsdh_databricks]
}

data "databricks_spark_version" "dbk_latest_lts" {
  long_term_support = true

  depends_on = [azurerm_private_endpoint.datahub_proj_databricks_api_ep]
}

data "databricks_spark_version" "dbk_latest_lts_ml" {
  long_term_support = true
  ml                = true

  depends_on = [azurerm_private_endpoint.datahub_proj_databricks_api_ep]
}

data "databricks_spark_version" "dbk_latest_lts_ml_gpu" {
  long_term_support = true
  ml                = true
  gpu               = true

  depends_on = [azurerm_private_endpoint.datahub_proj_databricks_api_ep]
}

resource "null_resource" "cluster_config" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      Invoke-RestMethod -Method PATCH -Uri "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/workspace-conf" -Headers @{Authorization = "Bearer ${databricks_token.terraform_pat.token_value}"} -Body '{"enableDcs": "true"}' -ContentType "application/json"
    EOT
    on_failure  = fail
  }
}

