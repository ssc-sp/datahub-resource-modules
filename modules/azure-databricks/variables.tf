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

variable "common_tags" {
  description = "Common tags map"
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

variable "budget_amount" {
  description = "Budget amount for the resource group"
  type        = number
  default     = 0
}

variable "budget_start_date" {
  description = "The start date of budget"
  type        = string
  default     = "2023-04-01T00:00:00Z"
}


