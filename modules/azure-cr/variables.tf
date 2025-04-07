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

variable "log_analytics_workspace_id" {
  description = "FSDH central LAW ID for storing audit and log"
  type        = string
}

variable "project_tags" {
  description = "Project workspace Common tags map"
  type        = map(any)
}

variable "sp_client_oid" {
  description = "Client OID / Principal of the Azure Service Principal"
  type        = string
}

variable "app_service_oid" {
  description = "ID of the app service"
  type        = string
}