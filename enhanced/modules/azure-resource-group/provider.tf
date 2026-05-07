provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  alias           = "root-workspace"
  subscription_id = var.automation_account_uai_sub
}
