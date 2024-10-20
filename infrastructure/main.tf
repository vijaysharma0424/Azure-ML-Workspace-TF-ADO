data "azurerm_client_config" "current" {}

// resource "azurerm_resource_group" "default" {
//   name     = var.resource_group_name
//   location = var.location
// }
data "azurerm_resource_group" "default" {
  name = var.resource_group_name
  #location = "eastus2"
}

// resource "random_pet" "prefix" {
//   prefix = var.prefix
//   length = 2
// }

// resource "random_integer" "suffix" {
//   min = 10000000
//   max = 99999999
// }