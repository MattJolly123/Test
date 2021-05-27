utput "subnet_ids" {
  value       = ["${azurerm_subnet.subnet.*.id}"]
  description = "Subnet ID's created by the Network Module"
}

output "created_subnets" {
  value       = zipmap(azurerm_subnet.subnet.*.name, azurerm_subnet.subnet.*.id)
  description = "A Map of created subnet names against their resource ID"
}

output "virtual_network_id" {
  value       = azurerm_virtual_network.virtual_network.id
  description = "The created virtual network ID"
}

output "virtual_network_name" {
  value       = azurerm_virtual_network.virtual_network.name
  description = "The created virtual network name"
}
