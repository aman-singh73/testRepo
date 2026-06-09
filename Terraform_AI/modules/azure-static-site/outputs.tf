output "id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_site.this.id
}

output "default_host_name" {
  description = "The default hostname of the Static Web App"
  value       = azurerm_static_site.this.default_host_name
}

output "api_key" {
  description = "The API key for the Static Web App (sensitive)"
  value       = azurerm_static_site.this.api_key
  sensitive   = true
}




