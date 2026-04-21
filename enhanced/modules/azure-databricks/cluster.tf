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

# # Serverless cluster profile: "spark.databricks.cluster.profile" : "serverless",
# resource "databricks_cluster" "dbk_proj_cluster" {
#   cluster_name            = "main_cluster"
#   spark_version           = data.databricks_spark_version.dbk_latest_lts.id
#   node_type_id            = "Standard_D4ds_v5"
#   driver_node_type_id     = "Standard_D4ds_v5"
#   autotermination_minutes = 10
#   num_workers             = 1
#   is_pinned               = true
#   policy_id               = databricks_cluster_policy.regular_cluster_policy.id

#   spark_conf = {
#     "spark.databricks.passthrough.enabled" : "true",
#     "spark.databricks.delta.preview.enabled" : "true",
#     "spark.databricks.pyspark.enableProcessIsolation" : "true",
#     "spark.databricks.repl.allowedLanguages" : "python,sql,r"
#   }

#   autoscale {
#     min_workers = 0
#     max_workers = 2
#   }

#   lifecycle {
#     ignore_changes = [node_type_id, driver_node_type_id]
#   }
# }

# resource "databricks_cluster" "dbk_proj_cluster_ml" {
#   count = var.enable_ml_cluster ? 1 : 0

#   cluster_name            = "ml_cluster"
#   spark_version           = data.databricks_spark_version.dbk_latest_lts_ml.id
#   node_type_id            = var.ml_compute
#   driver_node_type_id     = var.ml_compute
#   autotermination_minutes = 30
#   num_workers             = 1
#   is_pinned               = true
#   policy_id               = databricks_cluster_policy.ml_policy.id

#   spark_conf = {
#     "spark.databricks.passthrough.enabled" : "true",
#     "spark.databricks.delta.preview.enabled" : "true",
#     "spark.databricks.repl.allowedLanguages" : "python,sql,r"
#   }

#   autoscale {
#     min_workers = 1
#     max_workers = 4
#   }

#   lifecycle {
#     ignore_changes = [node_type_id, driver_node_type_id]
#   }
# }

# resource "databricks_cluster" "dbk_proj_cluster_ml_gpu" {
#   count = var.enable_ml_gpu_cluster ? 1 : 0

#   cluster_name            = "ml_gpu_cluster"
#   spark_version           = data.databricks_spark_version.dbk_latest_lts_ml_gpu.id
#   node_type_id            = var.ml_gpu_compute
#   driver_node_type_id     = var.ml_gpu_compute
#   autotermination_minutes = 30
#   num_workers             = 1
#   is_pinned               = true
#   policy_id               = databricks_cluster_policy.ml_gpu_policy.id

#   spark_conf = {
#     "spark.databricks.passthrough.enabled" : "true",
#     "spark.databricks.delta.preview.enabled" : "true",
#     "spark.databricks.repl.allowedLanguages" : "python,sql,r"
#     "spark.task.resource.gpu.amount"              = "1"
#     "spark.executor.resource.gpu.amount"          = "1"
#     "spark.executor.resource.gpu.discoveryScript" = "/databricks/spark/scripts/gpu/getGpusResources.sh"
#     "spark.resources.discoveryScript"             = "/databricks/spark/scripts/gpu/getGpusResources.sh"
#   }

#   autoscale {
#     min_workers = 1
#     max_workers = 2
#   }


#   lifecycle {
#     ignore_changes = [node_type_id, driver_node_type_id]
#   }
# }

resource "null_resource" "cluster_config" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      Invoke-RestMethod -Method PATCH -Uri "https://${azapi_resource.fsdh_databricks.output.properties.workspaceUrl}/api/2.0/workspace-conf" -Headers @{Authorization = "Bearer ${databricks_token.terraform_pat.token_value}"} -Body '{"enableDcs": "true"}' -ContentType "application/json"
    EOT
    on_failure  = fail
  }
}

