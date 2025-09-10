
# Azure subscription ID where the Fabric capacity will be deployed
# This variable is used to ensure deployment to the correct subscription
variable "subscription_id" {
  type        = string
  default     = "95ad0027-ffa7-4f15-8a92-76112d0073d9"
  description = "The Azure subscription ID where the Fabric capacity will be deployed"
}

# Resource group name where the Fabric capacity will be created
# All related resources will be deployed to this resource group
variable "resource_group" {
  type        = string
  default     = "fabricRG"
  description = "Name of the resource group for Fabric capacity deployment"
}

# Azure region where the Fabric capacity will be deployed
# Ensure the selected region supports Fabric capacity
variable "location" {
  type        = string
  default     = "eastUs"
  description = "Azure region for deploying the Fabric capacity (e.g., eastUs, westUs, etc.)"
}

# Name of the Fabric capacity resource
# This name will be used to identify the capacity in the Azure portal
variable "capacity_name" {
  type        = string
  default     = "fabric-st-capacity"
  description = "Name of the Fabric capacity resource in Azure"
}

# SKU name for the Fabric capacity
# Available SKUs: F2 (default), F4, F8, F16, F32, F64, F128, F256, F512
variable "sku_name" {
  type        = string
  default     = "F2"
  description = "SKU name for the Fabric capacity (F2-F512). Determines the performance tier."
}

# Administrator members for the Fabric capacity
# List of users/service principals who will have admin access
variable "admin_members" {
  type        = string
  default     = "shaleenthapa@shaleenthapahotmail.onmicrosoft.com"
  description = "Comma-separated list of User Principal Names (UPNs) or Service Principal Object IDs who will have administrator access to the Fabric capacity"
}
