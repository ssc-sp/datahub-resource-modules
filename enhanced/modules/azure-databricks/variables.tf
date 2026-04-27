# variables.tf
variable "environment_name" {
  description = "Short name for environment (e.g. dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "environment_classification" {
  description = "Max level of security the environment hosts"
  type        = string
  default     = "PA"
}

variable "project_cd" {
  description = "Project short code"
  type        = string
}

variable "az_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "az_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "resource_prefix" {
  description = "Resource name prefix for all resources"
  type        = string
  default     = "fsdh"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "resource_group_id" {
  description = "Resource group id"
  type        = string
}

variable "key_vault_id" {
  description = "Key vault ID"
  type        = string
}

variable "key_vault_url" {
  description = "Key vault URL"
  type        = string
}

variable "key_vault_cmk_id" {
  description = "Project CMK ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "FSDH central LAW ID for storing audit and log"
  type        = string
}

variable "project_tags" {
  description = "Project workspace common tags map"
  type        = map(any)
}

variable "run_in_devops" {
  description = "If this is being run in Azure DevOps, default to true"
  type        = bool
  default     = true
}

variable "admin_users" {
  description = "List of admin user emails"
  type        = list(any)
  default     = []
}

variable "project_lead_users" {
  description = "List of lead user emails"
  type        = list(any)
  default     = []
}

variable "project_users" {
  description = "List of regular user emails"
  type        = list(any)
  default     = []
}

variable "project_guest_users" {
  description = "List of guest user emails"
  type        = list(any)
  default     = []
}

variable "azure_databricks_enterprise_oid" {
  description = "Object ID of enterprise application AzureDatabricks"
  type        = string
}

variable "storage_acct_name" {
  description = "Name of the project storage account"
  type        = string
}

variable "storage_acct_id" {
  description = "ID of the project storage account"
  type        = string
}

variable "budget_amount" {
  description = "Budget amount for the resource group"
  type        = number
  default     = 0
}

variable "budget_start_date" {
  description = "The start date of budget"
  type        = string
  default     = ""
}

variable "log_workspace_id" {
  description = "The object ID of the pre-existing centrally managed Azure Log Analytics Workspace"
  type        = string
  default     = ""
}

variable "enable_ml_cluster" { default = false }
variable "enable_ml_gpu_cluster" { default = false }
variable "ml_compute" { default = "Standard_D4ds_v5" }
variable "ml_gpu_compute" { default = "Standard_NC4as_T4_v3" }
variable "vnet_name" {}
variable "vnet_rg" {}
variable "is_dev" { default = false }
variable "dbr_subnet_public" {}
variable "dbr_subnet_private" {}
variable "subnet_id_pep" {}
