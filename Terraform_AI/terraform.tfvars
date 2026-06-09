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
subscription_id = "8e01f6cc-5b9c-4ef8-b1b6-d22da79fc819"
user_api_node_version = "18-lts"