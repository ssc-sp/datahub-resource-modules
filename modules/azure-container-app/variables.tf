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

variable "key_vault_name" {
  description = "Key vault ID"
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

variable "project_tags" {
  description = "Project workspace common tags map"
  type        = map(any)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "FSDH central LAW ID for storing audit and log"
  type        = string
}

variable "container_app_size" { default = "D4" }
variable "container_app_max_node" { default = "2" }
variable "container_app_min_node" { default = "0" }
variable "container_app_profile" { default = "Consumption" }
