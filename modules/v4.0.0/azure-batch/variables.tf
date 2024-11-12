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

variable "key_vault_name" {
  description = "Key vault name"
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

variable "storage_acct_name" {
  description = "Name of the project storage account"
  type        = string
}

variable "storage_acct_id" {
  description = "ID of the project storage account"
  type        = string
}

variable "common_tags" {
  description = "Common tags map"
  type        = map(any)
}

variable "batch_default_vm_sku" {
  description = "The default SKU for the VM used in Azure Batch account"
  type        = string
  default     = "STANDARD_D3_V2"
}

variable "batch_vm_max" {
  description = "The max number of VM for the pool"
  type        = number
  default     = 2
}

variable "batch_starter_image_url" {
  description = "Password for Container Registry used by this batch account"
  type        = string
  default     = "ghcr.io/ssc-sp/dbr-sen2cor:latest"
}
