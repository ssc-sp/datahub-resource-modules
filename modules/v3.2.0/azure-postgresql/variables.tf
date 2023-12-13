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

variable "az_location" {
  description = "The Azure location to create the resources in"
  type        = string
  default     = "canadacentral"
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

variable "common_tags" {
  description = "Common tags map"
  type        = map(any)
}

#--------------
variable "psql_sku" {
  description = "SKU name for the PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "allow_source_ip_start" {
  description = "Start IP for allowed IP range to be configured with MyDSQL firewall rule "
  type        = string
  default     = ""
}

variable "allow_source_ip_end" {
  description = "End IP for allowed IP range to be configured with MyDSQL firewall rule"
  type        = string
  default     = ""
}

variable "allow_source_ip_list" {
  description = "End IP for allowed IP range to be configured with MyDSQL firewall rule"
  type        = list(string)
  default     = []
}

variable "psql_dba_group_name" {
  description = "AAD Group Name for the DBA"
  type        = string
  default     = ""
}

variable "psql_dba_group_oid" {
  description = "AAD Group OID for the DBA"
  type        = string
  default     = ""
}



