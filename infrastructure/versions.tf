terraform {
  required_version = "~> 1.7.5"

  // required_providers {
  //   azurerm = {
  //     source  = "hashicorp/azurerm"
  //     version = "~> 2"
  //   }
  //   random = {
  //     source  = "hashicorp/random"
  //     version = "~> 3"
  //   }
  //   tls = {
  //     source  = "hashicorp/tls"
  //     version = ">= 3.0.0"
  //   }
  // }
  backend "azurerm" {
    resource_group_name   = "your-resource-group"
    storage_account_name  = "your-storage-account"
    container_name        = "your-container"
    key                   = "your-key"
  }
}


  // cloud {
  //   organization = "olive-mercury"
  //   workspaces {
  //     tags = ["terraform", "pipelines"]
  //   }
  // }
