# ==============================================
#     Required Variables
# ==============================================

variable "az_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "az_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "project_cd" {
  description = "Project short code"
  type        = string
}

variable "datahub_app_object_id" {
  description = "The SP object ID used by the datahub app for granting KV access"
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

variable "common_tags" {
  description = "Common tags map"
  type        = map(any)
  default     = {}
}
