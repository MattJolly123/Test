output "vm_ids" {
  value       = azurerm_linux_virtual_machine.linux_vm.*.id
  description = "Ids of VMs for use in Backup Configs etc"
}

output "vm_nic_ids" {
  value       = azurerm_network_interface.linux_vm_nics.*.id
  description = "Ids of VM Nics for use when using the module"
}
