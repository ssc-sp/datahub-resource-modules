terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.18"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.40"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
    aws = {}
  }

  required_version = ">= 1.1"
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = "ca-central-1"
}

