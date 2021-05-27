#Vault for VM's backups
resource "azurerm_recovery_services_vault" "backups_vault" {
  name                = "${var.project_name}-${var.environment}-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

#Daily Backup Policy
resource "azurerm_backup_policy_vm" "vm_backup_policy" {
  name                = "${var.project_name}-${var.environment}-daily-policy"
  count               = var.vm_count
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backups_vault.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "12:00"
  }

  retention_daily {
    count = 30
  }
  depends_on = [azurerm_recovery_services_vault.backups_vault]
}
