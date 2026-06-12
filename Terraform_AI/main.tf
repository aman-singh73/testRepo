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
    tags = {
    cost_center = "governance-required"
    environment = "governance-required"
    owner = "governance-required"
    project = "governance-required"
    resulting in a tag completeness of 0% = "governance-required"
  }
}

# ========================================
# Phase: 2 Shared Infrastructure
# ========================================

# Module: app_service_plan (Removed due to Azure quota limits)

# ========================================
# Phase: 3 Data
# ========================================

# Module: database_cosmos (Removed to avoid existing resource conflicts)


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

# Module: user-api_app (Removed due to Azure quota limits)

# Module: main-react-app_app (azurerm_static_site)
module "main_react_app_app" {
  source = "./modules/azure-static-site"

  location            = var.location
  name                = "amanNew-dev-frontend"
  resource_group_name = module.main_rg.name
  sku_size            = "Free"
  sku_tier            = "Free"
  tags                = merge(var.tags, {
    cost_center = "governance-required"
    environment = "governance-required"
    owner = "governance-required"
    project = "governance-required"
    resulting in a tag completeness of 0 = "governance-required"
  })
}

# ========================================
# Phase: 5 AI Drift Testing (Test VM)
# ========================================

# 1. Virtual Network (Required for a VM)
resource "azurerm_virtual_network" "test_vnet" {
  name                = "perf-test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = module.main_rg.name
  tags                = merge(var.tags, {
    cost_center = "TBD"
    environment = "dev"
    owner = "TBD"
    project = "amanNew"
  })
}

# 2. Subnet
resource "azurerm_subnet" "test_subnet" {
  name                 = "perf-test-subnet"
  resource_group_name  = module.main_rg.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3. Public IP (Standard SKU to avoid Free tier limitations)
resource "azurerm_public_ip" "test_pip" {
  name                = "perf-test-pip"
  location            = var.location
  resource_group_name = module.main_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(var.tags, {
    cost_center = "TBD"
    environment = "dev"
    owner = "TBD"
    project = "amanNew"
  })
}

# 3.5 Network Security Group for SSH
resource "azurerm_network_security_group" "test_nsg" {
  name                = "perf-test-nsg"
  location            = var.location
  resource_group_name = module.main_rg.name
  tags                = merge(var.tags, {
    cost_center = "TBD"
    environment = "dev"
    owner = "TBD"
    project = "amanNew"
  })

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Attach NSG to NIC
resource "azurerm_network_interface_security_group_association" "test_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.perf_test_nic.id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}

# 4. Network Interface
resource "azurerm_network_interface" "perf_test_nic" {
  name                = "perf-test-nic"
  location            = var.location
  resource_group_name = module.main_rg.name
  tags                = merge(var.tags, {
    cost_center = "TBD"
    environment = "dev"
    owner = "TBD"
    project = "amanNew"
  })

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test_pip.id
  }
}

# 5. The Test Linux VM
resource "azurerm_linux_virtual_machine" "perf_test_vm" {
  name                = "perf-test-vm"
  resource_group_name = module.main_rg.name
  location            = var.location
  # Literal SKU required for SkuPatchEngine (Create PR path). Keep B1s for upsize PR test.
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  tags                = merge(var.tags, {
    cost_center = "TBD"
    environment = "dev"
    owner = "TBD"
    project = "amanNew"
  })

  network_interface_ids = [
    azurerm_network_interface.perf_test_nic.id
  ]
  
  # Using a password to make SSH very easy for testing
  admin_password                  = "TestP@ssw0rd1234!"
  disable_password_authentication = false

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

# ========================================
# Phase: 6 ACA TS-09 Testing
# ========================================

# 6. Container App Environment
resource "azurerm_container_app_environment" "test_env" {
  name                       = "perf-test-env"
  location                   = var.location
  resource_group_name        = module.main_rg.name
  log_analytics_workspace_id = module.log_analytics.id
}

# 7. Container App (Undersized for TS-09)
resource "azurerm_container_app" "test_aca" {
  name                         = "perf-test-aca"
  container_app_environment_id = azurerm_container_app_environment.test_env.id
  resource_group_name          = module.main_rg.name
  revision_mode                = "Single"

  template {
    container {
      name    = "stress-test"
      image   = "polinux/stress"
      command = ["stress"]
      args    = ["--vm", "1", "--vm-bytes", "450M", "--vm-hang", "0"]
      cpu     = 0.25
      memory  = "0.5Gi"
    }
  }
}
