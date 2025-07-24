resource "azurerm_container_app_environment" "proj_container_app_env" {
  name                       = "${local.base_name}-app-env"
  location                   = local.resource_group_location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_container_app_job" "proj_container_app_clamav_job" {
  name                         = "${local.base_name}-clamav-job"
  container_app_environment_id = azurerm_container_app_environment.proj_container_app_env.id
  location                     = local.resource_group_location
  resource_group_name          = var.resource_group_name
  replica_timeout_in_seconds   = 1800

  identity {
    type         = "UserAssigned"
    identity_ids = [var.clamav_job_uai]
  }

  registry {
    server   = "${var.acr_name}.azurecr.io"
    identity = var.clamav_job_uai
  }

  secret {
    name                = local.storage_conn_secret
    key_vault_secret_id = azurerm_key_vault_secret.storage_conn_secret.versionless_id
    identity            = var.clamav_job_uai
  }

  template {
    container {
      name   = "blobavscan"
      image  = "${var.acr_name}.azurecr.io/${var.clamav_acr_image}"
      cpu    = 2
      memory = "4.0Gi"
      env {
        name        = "storage_connection_string"
        secret_name = local.storage_conn_secret
      }
      env {
        name        = local.storage_conn_secret
        secret_name = local.storage_conn_secret
      }
    }
  }

  event_trigger_config {
    scale {
      polling_interval_in_seconds = 60
      max_executions              = 32
      rules {
        name = "blob-clamav-rule"
        metadata = {
          accountName       = azurerm_storage_account.datahub_storageaccount.name
          connectionFromEnv = local.storage_conn_secret
          queueLength       = "1024"
          queueName         = local.blob_created_queue
        }
        custom_rule_type = "azure-queue"
        authentication {
          secret_name       = local.storage_conn_secret
          trigger_parameter = "connection"
        }
      }
    }
  }
}
