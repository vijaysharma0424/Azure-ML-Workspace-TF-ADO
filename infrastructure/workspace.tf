# Dependent resources for Azure Machine Learning
resource "azurerm_application_insights" "default" {
  name                = "appi-${var.name}-${var.environment}"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  application_type    = "web"
}

resource "random_string" "kv_prefix" {
  length  = 4
  upper   = false
  special = false
  numeric = false
}

resource "azurerm_key_vault" "default" {
  name                     = "kv-${random_string.kv_prefix.result}-${var.environment}"
  location                 = data.azurerm_resource_group.default.location
  resource_group_name      = data.azurerm_resource_group.default.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "premium"
  purge_protection_enabled = true
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "random_string" "sa_prefix" {
  length  = 4
  upper   = false
  special = false
  numeric = false
}

resource "azurerm_storage_account" "default" {
  name                     = "st${random_string.sa_prefix.result}${var.environment}"
  location                 = data.azurerm_resource_group.default.location
  resource_group_name      = data.azurerm_resource_group.default.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  queue_properties  {
  logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 1
  }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

// resource "azurerm_container_registry" "default" {
//   name                = "cr${var.name}${var.environment}"
//   location            = data.azurerm_resource_group.default.location
//   resource_group_name = data.azurerm_resource_group.default.name
//   sku                 = "Premium"
//   admin_enabled       = true

//   network_rule_set {
//     default_action = "Deny"
//   }
//   public_network_access_enabled = false
// }

# Machine Learning workspace
resource "azurerm_machine_learning_workspace" "default" {
  name                    = "mlw-${var.name}-${var.environment}"
  location                = data.azurerm_resource_group.default.location
  resource_group_name     = data.azurerm_resource_group.default.name
  application_insights_id = azurerm_application_insights.default.id
  key_vault_id            = azurerm_key_vault.default.id
  storage_account_id      = azurerm_storage_account.default.id
  #container_registry_id   = azurerm_container_registry.default.id

  identity {
    type = "SystemAssigned"
  }

  # Args of use when using an Azure Private Link configuration
  public_network_access_enabled = false
  #image_build_compute_name      = var.image_build_compute_name
  depends_on = [
    azurerm_private_endpoint.kv_ple,
    azurerm_private_endpoint.st_ple_blob,
    azurerm_private_endpoint.storage_ple_file,
    #azurerm_private_endpoint.cr_ple,
    azurerm_subnet.snet-training
  ]

}

# Private endpoints
resource "azurerm_private_dns_zone" "dnsazureml" {
  name                = "privatelink.azureml.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "dnsnotebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "dnsvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "dnsstorageblob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "dnsstoragefile" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
}

// resource "azurerm_private_dns_zone" "dnscontainerregistry" {
//   name                = "privatelink.azurecr.io"
//   resource_group_name = var.resource_group_name
// }
resource "azurerm_private_endpoint" "kv_ple" {
  name                = "ple-${var.name}-${var.environment}-kv"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsvault.id]
  }

  private_service_connection {
    name                           = "psc-${var.name}-kv"
    private_connection_resource_id = azurerm_key_vault.default.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "st_ple_blob" {
  name                = "ple-${var.name}-${var.environment}-st-blob"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstorageblob.id]
  }

  private_service_connection {
    name                           = "psc-${var.name}-st"
    private_connection_resource_id = azurerm_storage_account.default.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "storage_ple_file" {
  name                = "ple-${var.name}-${var.environment}-st-file"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstoragefile.id]
  }

  private_service_connection {
    name                           = "psc-${var.name}-st"
    private_connection_resource_id = azurerm_storage_account.default.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

// resource "azurerm_private_endpoint" "cr_ple" {
//   name                = "ple-${var.name}-${var.environment}-cr"
//   location            = data.azurerm_resource_group.default.location
//   resource_group_name = data.azurerm_resource_group.default.name
//   subnet_id           = azurerm_subnet.snet-workspace.id

//   private_dns_zone_group {
//     name                 = "private-dns-zone-group"
//     private_dns_zone_ids = [azurerm_private_dns_zone.dnscontainerregistry.id]
//   }

//   private_service_connection {
//     name                           = "psc-${var.name}-cr"
//     private_connection_resource_id = azurerm_container_registry.default.id
//     subresource_names              = ["registry"]
//     is_manual_connection           = false
//   }
// }

resource "azurerm_private_endpoint" "mlw_ple" {
  name                = "ple-${var.name}-${var.environment}-mlw"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsazureml.id, azurerm_private_dns_zone.dnsnotebooks.id]
  }

  private_service_connection {
    name                           = "psc-${var.name}-mlw"
    private_connection_resource_id = azurerm_machine_learning_workspace.default.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }
  
}

# Compute cluster for image building required since the workspace is behind a vnet.
# For more details, see https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-create-secure-workspace#configure-image-builds.
// resource "azurerm_machine_learning_compute_cluster" "image-builder" {
//   name                          = var.image_build_compute_name
//   location                      = data.azurerm_resource_group.default.location
//   vm_priority                   = "LowPriority"
//   vm_size                       = "Standard_B1s"
//   machine_learning_workspace_id = azurerm_machine_learning_workspace.default.id
//   subnet_resource_id            = azurerm_subnet.snet-training.id

//   scale_settings {
//     min_node_count                       = 0
//     max_node_count                       = 1
//     scale_down_nodes_after_idle_duration = "PT15M" # 15 minutes
//   }

//   identity {
//     type = "SystemAssigned"
//   }
// }