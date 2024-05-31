terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.18"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.54"
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
  source                          = "github.com/ssc-sp/datahub-resource-modules//modules/{{version}}/azure-resource-group{{branch}}"
  az_tenant_id                    = var.az_tenant_id
  az_subscription_id              = var.az_subscription_id
  project_cd                      = var.project_cd
  environment_name                = var.environment_name
  datahub_app_sp_oid              = var.datahub_app_sp_oid
  automation_account_uai_clientid = var.automation_account_uai_clientid
  automation_account_uai_id       = var.automation_account_uai_id

  # optional variables
  budget_amount       = var.budget_amount
  common_tags         = var.common_tags
  aad_admin_group_oid = var.aad_admin_group_oid
}

output "project_cd" {
  value = module.resource_group_module.project_cd
}

output "new_project_template" {
  value = "completed"
}

output "workspace_version" {
  value = "{{version}}"
}

output "azure_resource_group_name" {
  value = module.resource_group_module.resource_group_name
}
