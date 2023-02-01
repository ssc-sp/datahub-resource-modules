terraform {
  backend "azurerm" {
    resource_group_name  = "sp-datahub-iac-rg"
    storage_account_name = "sscdataterraformbackend"
    container_name       = "fsdh-project-v2"
    key                  = "fsdh-sw2.tfstate"
  }
}

variable "az_subscription" {
  default = "bc4bcb08-d617-49f4-b6af-69d6f10c240b"
}

variable "az_tenant" {
  default = "8c1a4d93-d828-4d0e-9303-fd3bd611c822"
}

variable "az_databricks_sp" {
  default = "22aaf48e-092a-47d6-9fc5-d24d762753d4"
}

variable "project_cd" {
  default = "sw2"
}

variable "datahub_app_object_id" {
  default = "d34005c9-92b4-48fd-9d39-d1e881c0d3da"
}

locals {
  common_tags = {
    sector             = "Science Program"
    Environment        = "sw2"
    clientOrganization = "SW2-SW2"
  }

  databricks_admin_users = [
    { "email" = "not-in-use-1@ssc-spc.gc.ca" },
    { "email" = "not-in-use-2@ssc-spc.gc.ca" }
  ]

  storage_contributor_users = [
    { "email" = "not-in-use-1@ssc-spc.gc.ca", "oid" = "6580c942-fe69-4795-94bf-a5937656869e" }
  ]
}
