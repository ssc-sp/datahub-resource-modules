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

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
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
  source             = "github.com/ssc-sp/datahub-resource-modules/modules/azure-resource-group"
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd
  common_tags        = var.common_tags
}

output "project_cd" {
  value = module.resource_group_module.project_cd
}