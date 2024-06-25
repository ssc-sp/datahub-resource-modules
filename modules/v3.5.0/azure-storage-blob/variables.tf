# ==============================================
#     Required Variables
# ==============================================
variable "az_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "az_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "project_cd" {
  description = "Project short code"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "key_vault_id" {
  description = "Key vault ID"
  type        = string
}

variable "key_vault_cmk_name" {
  description = "Project CMK name"
  type        = string
}

variable "automation_acct_principal_id" {
  description = "Automation account UAI"
  type        = string
}


# ==============================================
#     Optional Variables
# ==============================================
variable "environment_classification" {
  description = "Max level of security the environment hosts"
  type        = string
  default     = "U"
}

variable "environment_name" {
  description = "Short name for environment (e.g. dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "az_location" {
  description = "The Azure location to create the resources in"
  type        = string
  default     = "canadacentral"
}

variable "resource_prefix" {
  description = "Resource name prefix for all resources"
  type        = string
  default     = "fsdh"
}

variable "resource_prefix_alphanumeric" {
  description = "Aphanumeric resource name prefix for resources. All lower case"
  type        = string
  default     = "fsdh"
}

variable "storage_suffix" {
  description = "Resource name suffix for resources"
  type        = string
  default     = "tfbackend"
}

variable "common_tags" {
  description = "Common tags map"
  type        = map(any)
  default     = {}
}

variable "storage_contributor_users" {
  description = "A list of users to be assigned the role of Storage Blob Data Contributor"
  type        = list(any)
  default     = []
}

variable "storage_reader_users" {
  description = "A list of users to be assigned the role of Storage Blob Data Reader"
  type        = list(any)
  default     = []
}

variable "storage_size_limit_tb" {
  description = "Storage account size limit for alerts"
  type        = number
  default     = 0
}


