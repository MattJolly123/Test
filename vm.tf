#Creation of VM NIC's

resource "azurerm_network_interface" "linux_vm_nics" {
  name                    = "${var.project_name}-${var.environment}-${format("%02d", count.index + 1)}-nic"
  location                = var.location
  resource_group_name     = var.resource_group_name
  count                   = var.vm_count
  internal_dns_name_label = var.vm_count > 1 ? "${var.project_name}-${format("%02d", count.index + 1)}" : "${var.project_name}"

  ip_configuration {
    name                          = "ipconf"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.ip_address == "" ? "dynamic" : "static"
    private_ip_address            = var.vm_count > 1 ? element(split(",", var.ip_address), count.index) : var.ip_address
    public_ip_address_id          = var.vm_count > 1 ? element(split(",", var.public_ip), count.index) : var.public_ip
  }
}

#Diagnostic settings for NIC
resource "azurerm_monitor_diagnostic_setting" "nic" {
  name                       = "nic_diagnostics"
  count                      = length(azurerm_network_interface.linux_vm_nics.*.id)
  target_resource_id         = azurerm_network_interface.linux_vm_nics.*.id[count.index]
  log_analytics_workspace_id = var.workspace_rid

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 180
    }
  }
  depends_on = [azurerm_network_interface.linux_vm_nics]
}

#Linux VM Creation
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = "${var.project_name}-${var.environment}-${format("%02d", count.index + 1)}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  count                           = var.vm_count
  network_interface_ids           = ["${element(azurerm_network_interface.linux_vm_nics.*.id, count.index)}"]
  admin_username                  = "${var.project_name}-${var.environment}-adm"
  disable_password_authentication = true

  os_disk {
    name                 = "${var.project_name}-${var.environment}${format("%02d", count.index + 1)}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.disk_performance_tier
    disk_size_gb         = var.os_disk_size_gb

  }

  admin_ssh_key {
    username   = "${var.project_name}-${var.environment}-adm"
    public_key = chomp(tls_private_key.vm_ssh_key.public_key_openssh)
  }

  #Using the packer image created in /packer. This will install the dotnet requirements:
  source_image_id = var.storage_image_id
  depends_on      = [azurerm_network_interface.linux_vm_nics]
}
