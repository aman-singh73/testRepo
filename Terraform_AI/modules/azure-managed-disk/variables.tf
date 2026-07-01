variable "name" {
  description = "Name of the managed disk"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_type" {
  description = "Storage account type for the managed disk (e.g. Standard_LRS)"
  type        = string
  default     = "Standard_LRS"
}

variable "create_option" {
  description = "Disk create option (Empty, FromImage, Copy, etc.)"
  type        = string
  default     = "Empty"
}

variable "disk_size_gb" {
  description = "Size of the managed disk in GB"
  type        = number
  default     = 128
}

variable "tags" {
  description = "Tags to apply to the managed disk"
  type        = map(string)
  default     = {}
}
