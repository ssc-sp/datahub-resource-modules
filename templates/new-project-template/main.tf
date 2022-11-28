terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.18"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.29"
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
  
}

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}



locals {
  common_tags = {
    sector             = "Science Program"
    Environment        = "test"
    clientOrganization = "TEST-TEST"
  }

  databricks_admin_users = [
    { "email" = "not-in-use@ssc-spc-gc.ca" }
  ]

  tf_backend_key = lower("fsdh-${var.project_cd}-terraform.tfstate")
}

module "resource_group_module" {
  source             = "github.com/ssc-sp/datahub-resource-modules/modules/azure-resource-group"
  az_tenant_id       = var.az_tenant
  az_subscription_id = var.az_subscription
  project_cd         = var.project_cd
  common_tags        = local.common_tags
}