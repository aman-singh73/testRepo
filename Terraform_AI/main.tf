# Terraform configuration generated from Resource Plan
# Environment: dev
# Generated from deterministic resource plan (Phase 2)

terraform {
  required_version = ">= 1.5.0"
   backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "amantfstate2026"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# ========================================
# Phase: 1 Foundation
# ========================================

# Module: rg_main (azurerm_resource_group)
module "main_rg" {
  source = "./modules/azure-resource-group"

  location = var.location
  name     = "amanNew-dev-rg"
  tags     = var.tags
}

# Module: log_analytics (azurerm_log_analytics_workspace)
module "log_analytics" {
  source = "./modules/azure-log-analytics-workspace"

  location            = var.location
  name                = "amanNew-dev-log"
  resource_group_name = module.main_rg.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

# ========================================
# Phase: 2 Shared Infrastructure
# ========================================

# Module: app_service_plan (azurerm_service_plan)
module "shared_plan" {
  source = "./modules/azure-app-service-plan"

  kind                = "Linux"
  location            = var.location
  name                = "amanNew-dev-infrastructure"
  resource_group_name = module.main_rg.name
  sku = {
    tier     = "Basic"
    size     = "B1"
    capacity = 1
  }
  tags = var.tags
}

# ========================================
# Phase: 3 Data
# ========================================

# Module: database_account (azurerm_cosmosdb_account)
module "database_cosmos" {
  source = "./modules/azure-cosmosdb-account"

  consistency_policy              = var.consistency_policy
  enable_automatic_failover       = true
  enable_multiple_write_locations = false
  geo_location                    = var.geo_location
  kind                            = "MongoDB"
  location                        = var.location
  name                            = "amannew-dev-cosmos"
  offer_type                      = "Standard"
  resource_group_name             = module.main_rg.name
  tags                            = var.tags
}

# Module: inferred-storage_account (azurerm_storage_account)
module "inferred_storage_account" {
  source = "./modules/azure-storage-account"

  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  enable_https_traffic_only = true
  location                  = var.location
  min_tls_version           = "TLS1_2"
  name                      = "amannewdevstorage"
  resource_group_name       = module.main_rg.name
  tags                      = var.tags
}

# ========================================
# Phase: 4 Compute
# ========================================

# Module: user-api_app (azurerm_linux_web_app)
module "user_api_app" {
  source = "./modules/azure-linux-web-app"

  app_settings = {
  }
  enable_system_identity = true
  https_only             = true
  location               = var.location
  name                   = "amanNew-dev-backend"
  resource_group_name    = module.main_rg.name
  runtime_stack = {
    language = "node"
    version  = var.user_api_node_version
  }
  service_plan_id = module.shared_plan.id
  tags            = var.tags
}

# Module: main-react-app_app (azurerm_static_site)
module "main_react_app_app" {
  source = "./modules/azure-static-site"

  location            = var.location
  name                = "amanNew-dev-frontend"
  resource_group_name = module.main_rg.name
  sku_size            = "Free"
  sku_tier            = "Free"
  tags                = var.tags
}
resource "azurerm_network_interface" "perf_test_nic" {
  name                = "perf-test-nic"
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.main.name  # use your existing RG resource name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id  # your existing subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "perf_test_vm" {
  name                = "perf-test-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  size                = "Standard_B1s"   # literal — required for PR patch
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.perf_test_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # or your key path
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}