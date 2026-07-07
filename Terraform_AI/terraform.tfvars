consistency_policy = {
  consistency_level = "Session"
  max_interval_in_seconds = 5
  max_staleness_prefix = 100
}
geo_location = [
{
    failover_priority = 0
    location = "eastus2"
  },
]
environment = "dev"
location = "eastus2"
subscription_id = "e024cc04-bbe6-4d17-8cf9-950081336ef4"
user_api_node_version = "18-lts"
tags = {
  owner       = "TBD"
  environment = "dev"
  cost_center = "TBD"
  project     = "amanNew"
}
