terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
// locals {
//   _unused_env_subscription_id = var.env_subscription_id
// }
provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults    = false
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  // client_id       = var.client_id
  // client_secret   = var.client_secret
  // subscription_id = var.env_subscription_id
  // tenant_id       = var.tenant_id
  }
  subscription_id = var.env_subscription_id
}