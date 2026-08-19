# Version {{version}}

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.18"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }

  required_version = ">= 1.1"

  backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = var.az_subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

  }
}

data "azurerm_client_config" "current" {}

locals {
  databricks_admin_users = [
    { "email" = "not-in-use@ssc-spc-gc.ca" }
  ]
}

module "resource_group_module" {
  source                      = "github.com/ssc-sp/datahub-resource-modules//modules/azure-resource-group{{tag}}"
  az_tenant_id                = var.az_tenant_id
  az_subscription_id          = var.az_subscription_id
  project_cd                  = var.project_cd
  environment_name            = var.environment_name
  datahub_app_sp_oid          = var.datahub_app_sp_oid
  automation_account_uai_name = var.automation_account_uai_name
  automation_account_uai_rg   = var.automation_account_uai_rg
  automation_account_uai_sub  = var.automation_account_uai_sub
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  service_bus_name            = var.service_bus_name
  service_bus_id              = var.service_bus_id

  # optional variables
  budget_amount       = var.budget_amount
  common_tags         = var.common_tags
  ssc_cbrid           = var.ssc_cbrid
  aad_admin_group_oid = var.aad_admin_group_oid

  blob_scan_image = "ghcr.io/ssc-sp/clamav-blobavscan@sha256:f22d2c0ab5b938e2f3a68045ec0566c239da146b25363a9c55fb9442dbd30f7b"
}

output "project_cd" {
  value = module.resource_group_module.project_cd
}

output "new_project_template" {
  value = "completed"
}

output "azure_resource_group_name" {
  value = module.resource_group_module.resource_group_name
}

output "azure_storage_account_name" {
  value = module.resource_group_module.azure_storage_account_name
}

output "azure_storage_container_name" {
  value = module.resource_group_module.azure_storage_container_name
}

output "azure_storage_blob_status" {
  value = "completed"
}

output "workspace_version" {
  value = "{{version}}"
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_account.datahub_storageaccount
  to   = module.resource_group_module.azurerm_storage_account.datahub_storageaccount
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_container.datahub_quarantine
  to   = module.resource_group_module.azurerm_storage_container.datahub_quarantine
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_container.datahub_log
  to   = module.resource_group_module.azurerm_storage_container.datahub_log
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_container.datahub_log
  to   = module.resource_group_module.azurerm_storage_container.datahub_log
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_share.file_share_default
  to   = module.resource_group_module.azurerm_storage_share.file_share_default
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_share.file_share_clamav_temp
  to   = module.resource_group_module.azurerm_storage_share.file_share_clamav_temp
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_queue.blob_job_disabled_event_queue
  to   = module.resource_group_module.azurerm_storage_queue.blob_job_disabled_event_queue
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_queue.blob_created_event_queue
  to   = module.resource_group_module.azurerm_storage_queue.blob_created_event_queue
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_container.datahub_default
  to   = module.resource_group_module.azurerm_storage_container.datahub_default
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_container.datahub_backup
  to   = module.resource_group_module.azurerm_storage_container.datahub_backup
}

moved {
  from = module.azure_storage_blob_module.azurerm_storage_blob.datahub_sample_blob
  to   = module.resource_group_module.azurerm_storage_blob.datahub_sample_blob
}