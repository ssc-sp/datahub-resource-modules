resource "azurerm_container_app_job" "proj_container_app_clamav_job" {
  name                         = "${local.base_name}-clamav-job"
  container_app_environment_id = var.container_app_env_id
  location                     = local.resource_group_location
  resource_group_name          = var.resource_group_name
  replica_timeout_in_seconds   = 1800

  identity {
    type         = "UserAssigned"
    identity_ids = [var.clamav_job_uai]
  }

  secret {
    name                = local.storage_conn_secret
    key_vault_secret_id = azurerm_key_vault_secret.storage_conn_secret.versionless_id
    identity            = var.clamav_job_uai
  }

  template {
    container {
      name   = "blobavscan"
      image  = var.clamav_docker_image
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
      env {
        name  = "container_name"
        value = "${local.datahub_mount_name},${local.datahub_stage_name}"
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
}

resource "azurerm_container_app_job" "proj_container_app_job_sas_token" {
  name                         = "${local.base_name}-sas-job"
  container_app_environment_id = var.container_app_env_id
  location                     = local.resource_group_location
  resource_group_name          = var.resource_group_name
  replica_timeout_in_seconds   = 1800

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_proj_sas_token_job_uai.id, var.clamav_job_uai]
  }

  template {
    container {
      name   = "proj-sas-job"
      image  = var.sas_docker_image
      cpu    = 2
      memory = "4.0Gi"
      env {
        name  = "PROJ_CD"
        value = var.project_cd
      }
      env {
        name  = "PROJ_RG"
        value = var.resource_group_name
      }
      env {
        name  = "PROJ_KV"
        value = var.key_vault_name
      }
      env {
        name  = "PROJ_SUB"
        value = var.az_subscription_id
      }
      env {
        name  = "PROJ_STORAGE_ACCT"
        value = azurerm_storage_account.datahub_storageaccount.name
      }
      env {
        name  = "CLIENT_ID"
        value = azurerm_user_assigned_identity.datahub_proj_sas_token_job_uai.client_id
      }
    }
  }

  schedule_trigger_config { cron_expression = "15 3 * * *" }
}

