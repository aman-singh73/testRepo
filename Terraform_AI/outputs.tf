# Outputs for Terraform configuration
# Environment: dev

output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = module.shared_plan.id
}

output "database_connection_string" {
  description = "Connection string for database"
  sensitive   = true
  value       = module.database_cosmos.connection_strings[0]
}

output "database_endpoint" {
  description = "Endpoint for database"
  value       = module.database_cosmos.endpoint
}

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

output "user-api_id" {
  description = "Resource ID of user-api"
  value       = module.user_api_app.id
}

output "user-api_url" {
  description = "URL of user-api"
  value       = module.user_api_app.default_hostname
}
