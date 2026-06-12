# Outputs for Terraform configuration
# Environment: dev

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.log_analytics.id
}

output "main-react-app_url" {
  description = "URL of main-react-app"
  value       = module.main_react_app_app.default_host_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.main_rg.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.main_rg.name
}

output "perf_test_vm_public_ip" {
  description = "Public IP for perf-test-vm (SSH / stress suite)"
  value       = azurerm_public_ip.test_pip.ip_address
}

output "perf_test_vm_terraform_address" {
  description = "Terraform address used by healing SKU patch PR"
  value       = "azurerm_linux_virtual_machine.perf_test_vm"
}
