terraform {
  backend "azurerm" {
    resource_group_name  = "sp-datahub-iac-rg"
    storage_account_name = "sscdataterraformbackend"
    container_name       = "fsdh-project-v2"
    key                  = "fsdh-sw2.tfstate"
  }
}