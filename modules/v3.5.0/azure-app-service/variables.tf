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

variable "storage_acct_key" {
  description = "Name of the project storage account"
  type        = string
  sensitive   = true
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

variable "app_image_name" {
  description = "Docker image name and tag"
  type        = string
  default     = "ssc-sp/shiny-app:latest"
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
  description = "AKV ID hosting SSL cert (required if use_easy_auth is true)"
  type        = string
  default     = ""
}

variable "sp_client_id" {
  description = "Client ID of the Azure Service Principal for register login redirect URI (required if use_easy_auth is true)"
  type        = string
  default     = ""
}

variable "allow_source_ip" {
  description = "The only source IP of the reverse proxy that is allowed to call the Azure App Service (required if use_easy_auth is false)"
  type        = string
  default     = ""
}

variable "use_easy_auth" {
  description = "If we use easy auth for Azure App Service (custom domain, custom domain, cert binding and redirect URI to the app registration)"
  type        = bool
  default     = false
}

variable "acr_id" {
  description = "Private Azure Container Registry that is used for Docker images"
  type        = string
  default     = ""
}
