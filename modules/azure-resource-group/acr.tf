resource "azurerm_container_registry" "datahub_proj_acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
  admin_enabled       = true
  sku                 = "Basic"

  encryption {
    key_vault_key_id   = azurerm_key_vault_key.az_proj_cmk.id
    identity_client_id = azurerm_user_assigned_identity.datahub_proj_acr_uai.client_id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.datahub_proj_acr_uai.id
    ]
  }
}

resource "azurerm_role_assignment" "acr_role_sp" {
  scope                = azurerm_container_registry.datahub_proj_acr.id
  principal_id         = var.datahub_app_sp_oid
  role_definition_name = "Contributor"
}

resource "azurerm_container_registry_task" "refresh_blob_scan_image" {
  name                  = "refresh-blob-scan-image"
  container_registry_id = azurerm_container_registry.datahub_proj_acr.id
  platform { os = "Linux" }
  identity { type = "SystemAssigned" }

  timer_trigger {
    name     = "daily-refresh-2am"
    schedule = "0 5 * * *" # Every day at 2 AM UTC
    enabled  = true
  }
  encoded_step {
    task_content = base64encode(<<-EOF
      version: v1.1.0
      steps: 
      - cmd: az login --identity --allow-no-subscriptions
      - cmd: docker pull ${var.blob_scan_image} && docker tag ${var.blob_scan_image} ${azurerm_container_registry.datahub_proj_acr.name}.azurecr.io/${local.acr_image_clamav} && docker push ${azurerm_container_registry.datahub_proj_acr.name}.azurecr.io/${local.acr_image_clamav}
      EOF
    )
  }
}

resource "azurerm_container_registry_task" "refresh_proj_cost_image" {
  name                  = "refresh-proj-cost-image"
  container_registry_id = azurerm_container_registry.datahub_proj_acr.id
  platform { os = "Linux" }
  identity { type = "SystemAssigned" }

  timer_trigger {
    name     = "daily-refresh-2am"
    schedule = "15 5 * * *" # Every day at 2 AM UTC
    enabled  = true
  }
  encoded_step {
    task_content = base64encode(<<-EOF
      version: v1.1.0
      steps: 
      - cmd: az login --identity --allow-no-subscriptions
      - cmd: docker pull ${var.proj_cost_image} && docker tag ${var.proj_cost_image} ${azurerm_container_registry.datahub_proj_acr.name}.azurecr.io/${local.acr_image_proj_cost} && docker push ${azurerm_container_registry.datahub_proj_acr.name}.azurecr.io/${local.acr_image_proj_cost}
      EOF
    )
  }
}

resource "azurerm_container_registry_task" "refresh_proj_job_image" {
  name                  = "refresh-proj-job-image"
  container_registry_id = azurerm_container_registry.datahub_proj_acr.id
  platform { os = "Linux" }
  identity { type = "SystemAssigned" }

  timer_trigger {
    name     = "daily-refresh-2am"
    schedule = "10 5 * * *" # Every day at 2 AM UTC
    enabled  = true
  }
  encoded_step {
    task_content = base64encode(<<-EOF
      version: v1.1.0
      steps: 
      - cmd: az login --identity --allow-no-subscriptions
      - cmd: docker pull ${var.proj_job_image} && docker tag ${var.proj_job_image} ${azurerm_container_registry.datahub_proj_acr.name}.azurecr.io/${local.acr_image_proj_job} && docker push ${azurerm_container_registry.datahub_proj_acr.name}.azurecr.io/${local.acr_image_proj_job}
      EOF
    )
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "acr_image_clamav" {
  container_registry_task_id = azurerm_container_registry_task.refresh_blob_scan_image.id
}

resource "azurerm_container_registry_task_schedule_run_now" "acr_image_proj_cost" {
  container_registry_task_id = azurerm_container_registry_task.refresh_blob_scan_image.id
}

resource "azurerm_container_registry_task_schedule_run_now" "acr_image_proj_job" {
  container_registry_task_id = azurerm_container_registry_task.refresh_blob_scan_image.id
}


