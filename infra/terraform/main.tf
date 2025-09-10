
# Azure Fabric Capacity Resource
# This resource creates a Fabric capacity instance in Azure, which provides dedicated
# resources for Power BI, PowerApps, and other Microsoft Fabric services.
resource "azurerm_fabric_capacity" "cap" {
  # Name of the Fabric capacity resource
  name                = var.capacity_name
  # Resource group where the capacity will be deployed
  resource_group_name = var.resource_group
  # Azure region for the capacity deployment
  location            = var.location

  # SKU configuration for the Fabric capacity
  # This determines the performance level and pricing tier
  sku {
    # SKU name (F2-F512) defining the capacity level
    name = var.sku_name
    # Service tier - fixed as "Fabric" for Microsoft Fabric capacity
    tier = "Fabric"
  }

  # List of administrators who can manage the Fabric capacity
  # Converts comma-separated string to list of administrator members
  administration_members = split(",", var.admin_members)

  # Resource tags for tracking and organization
  # Indicates this resource was provisioned through GitHub Actions
  tags = { provisionedBy = "github-actions" }
}
