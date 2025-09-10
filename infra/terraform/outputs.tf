
# Output: Fabric Capacity Resource ID
# This outputs the unique Azure resource ID of the created Fabric capacity
# The ID can be used for referencing this resource in other Azure services
# or for management operations through Azure APIs
output "capacity_id" {
  value       = azurerm_fabric_capacity.cap.id
  description = "The fully qualified Azure resource ID of the deployed Fabric capacity"
}
