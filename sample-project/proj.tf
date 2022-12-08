terraform {
  backend "azurerm" {
    resource_group_name  = "sp-datahub-iac-rg"
    storage_account_name = "sscdataterraformbackend"
    container_name       = "fsdh-project-v2"
    key                  = "fsdh-test.tfstate"
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
  default = "test"
}

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
