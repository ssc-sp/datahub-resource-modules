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

variable "app_service_sku" {
  description = "Project Azure App Service Plan SKU"
  type        = string
  default     = "B3"
}

variable "worker_count_init" {
  description = "If this is being run in Azure DevOps, default to true"
  type        = number
  default     = 1
}

variable "docker_server_url" {
  description = "CR server URL"
  type        = string
  default     = "https://ghcr.io"
}

variable "shiny_image_name" {
  description = "Shiny app image name"
  type        = string
  default     = "ghcr.io/ssc-sp/shiny-app"
}

variable "shiny_image_tag" {
  description = "Shiny app image tag"
  type        = string
  default     = "latest"
}

variable "fsdh_dns_zone_name" {
  description = "DNS Zone name for FSDH"
  type        = string
  default     = "fsdh-dhsf.science.cloud-nuage.canada.ca"
}

variable "fsdh_dns_zone_rg" {
  description = "Azure RG name for DNS zone"
  type        = string
  default     = "sp-datahub-iac-rg"
}

variable "ssl_cert_name" {
  description = "SSL cert name for DNS records"
  type        = string
  default     = "datahub-ssl"
}

variable "ssl_cert_kv_id" {
  description = "AKV ID hosting SSL cert"
  type        = string
}

variable "sp_client_id" {
  description = "Client ID of the Azure Service Principal for register login redirect URI"
  type        = string
}

