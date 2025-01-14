variable "name" {
  type        = string
  description = "Name of the deployment"
  default     = "workspacedeployment"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  default     = "dev"
}

// variable "location" {
//   type        = string
//   description = "Location of the resources"
//   default     = "East US"
// }

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space of the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "training_subnet_address_space" {
  type        = list(string)
  description = "Address space of the training subnet"
  default     = ["10.0.1.0/24"]
}

variable "aks_subnet_address_space" {
  type        = list(string)
  description = "Address space of the aks subnet"
  default     = ["10.0.2.0/23"]
}

variable "ml_subnet_address_space" {
  type        = list(string)
  description = "Address space of the ML workspace subnet"
  default     = ["10.0.0.0/24"]
}

// variable "dsvm_subnet_address_space" {
//   type        = list(string)
//   description = "Address space of the DSVM subnet"
//   default     = ["10.0.4.0/24"]
// }

// variable "bastion_subnet_address_space" {
//   type        = list(string)
//   description = "Address space of the bastion subnet"
//   default     = ["10.0.5.0/24"]
// }

// variable "image_build_compute_name" {
//   type        = string
//   description = "Name of the compute cluster to be created and set to build docker images"
//   default     = "image-builder"
// }

// # DSVM Variables
// variable "dsvm_name" {
//   type        = string
//   description = "Name of the Data Science VM"
//   default     = "vmdsvm01"
// }
// variable "dsvm_admin_username" {
//   type        = string
//   description = "Admin username of the Data Science VM"
//   default     = "azureadmin"
// }

// variable "dsvm_host_password" {
//   type        = string
//   description = "Password for the admin username of the Data Science VM"
//   default     = "ChangeMe123!"
//   sensitive   = true
// }

variable "resource_group_name" {
  description = "The name of the resource group for this project."
  type        = string
}
variable "env_subscription_id" {
  description = "The subscription ID for the environment"
  type        = string
}


// variable "client_id" {
//   default     = null
//   description = "The AzureAD Appication Client ID"
//   type        = string
// }

// variable "client_secret" {
//   default     = null
//   description = "The AzureAD Application Password"
//   sensitive   = true
//   type        = string
// }

// variable "subscription_id" {
//   default     = null
//   description = "The Azure subscription ID"
//   type        = string
// }
// variable "env_subscription_id" {
//   description = "The subscription ID for the environment"
//   type        = string
// }

// variable "tenant_id" {
//   default     = null
//   description = "The Azure AD tenant ID"
//   type        = string
// }
// variable "vm_name" {
//   default = "test-vm"
//   type    = string
//   description = "vm name"
// }