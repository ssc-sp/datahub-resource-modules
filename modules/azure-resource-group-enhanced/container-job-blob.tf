resource "azurerm_container_app_job" "proj_container_app_clamav_job" {
  name                         = "${local.base_name}-clamav-job"
  container_app_environment_id = azurerm_container_app_environment.proj_container_app_env.id
  location                     = local.resource_group_location
  resource_group_name          = azurerm_resource_group.az_project_rg.name
  replica_timeout_in_seconds   = 1800

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.id, azurerm_user_assigned_identity.datahub_proj_aca_env_uai.id]
  }

  secret {
    name                = local.storage_conn_secret
    key_vault_secret_id = azurerm_key_vault_secret.storage_conn_secret.versionless_id
    identity            = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.id
  }

  template {
    container {
      name   = "blobavscan"
      image  = var.blob_scan_image
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
      env {
        name  = "WORK_DIR"
        value = "/${local.datahub_temp_name}"
      }
      volume_mounts {
        name = local.datahub_temp_name
        path = "/${local.datahub_temp_name}"
      }
    }

    volume {
      name          = local.datahub_temp_name
      storage_name  = azurerm_container_app_environment_storage.datahub_temp.name
      mount_options = "dir_mode=0777,file_mode=0777"
    }
  }

  event_trigger_config {
    scale {
      polling_interval_in_seconds = 60
      max_executions              = 32
      rules {
        name = "blob-clamav-rule"
        metadata = {
          accountName         = azurerm_storage_account.datahub_storageaccount.name
          connectionFromEnv   = local.storage_conn_secret
          queueLength         = "1024"
          queueName           = var.enable_clamav ? local.blob_created_queue : local.blob_muted_queue
          queueLengthStrategy = "visibleonly"
        }
        custom_rule_type = "azure-queue"
        authentication {
          secret_name       = local.storage_conn_secret
          trigger_parameter = "connection"
        }
      }
    }
  }

  depends_on = [azurerm_key_vault_access_policy.kv_policy_clamav_job]
}


resource "azapi_update_resource" "proj_container_app_clamav_job_auth" {
  type        = "Microsoft.App/jobs@2025-07-01"
  resource_id = azurerm_container_app_job.proj_container_app_clamav_job.id
  body = {
    properties = {
      configuration = {
        eventTriggerConfig = {
          scale = {
            rules = [
              {
                auth     = []
                identity = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.id
              }
            ]
          }
        }
      }
    }
  }

  lifecycle {
    replace_triggered_by = [ azurerm_container_app_job.proj_container_app_clamav_job ]
  }
}


