resource "azurerm_container_app_job" "proj_container_app_job_costing" {
  name                         = "${local.base_name}-costing-job"
  container_app_environment_id = azurerm_container_app_environment.proj_container_app_env.id
  location                     = local.resource_group_location
  resource_group_name          = azurerm_resource_group.az_project_rg.name
  replica_timeout_in_seconds   = 1800

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.proj_auto_acct_uai.id]
  }

  template {
    container {
      name   = "proj-cost"
      image  = local.docker_image_proj_cost
      cpu    = 2
      memory = "4.0Gi"
      env {
        name  = "PROJ_CD"
        value = var.project_cd
      }
      env {
        name  = "PROJ_RG"
        value = azurerm_resource_group.az_project_rg.name
      }
      env {
        name  = "PROJ_DBR_RG"
        value = local.databricks_rg_name
      }
      env {
        name  = "PROJ_KV"
        value = azurerm_key_vault.az_proj_kv.name
      }
      env {
        name  = "PROJ_SUB"
        value = var.az_subscription_id
      }
      env {
        name  = "PROJ_BUDGET"
        value = var.budget_amount
      }
      env {
        name  = "CLIENT_ID"
        value = data.azurerm_user_assigned_identity.proj_auto_acct_uai.client_id
      }
    }
  }

  schedule_trigger_config { cron_expression = "5 3 * * *" }
}
