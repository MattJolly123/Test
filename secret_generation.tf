#Creation of Key Vault in separate Resrouce Group
resource "azurerm_resource_group" "kv_resource_group" {
  name     = var.kv_resource_group_name
  location = var.kv_location
}

#Creation of Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = "${var.project_name}-${var.environment}-kv"
  location                   = azurerm_resource_group.kv_resource_group.location
  resource_group_name        = azurerm_resource_group.kv_resource_group.name
  tenant_id                  = var.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
}

#Generates an RSA Encryption Key for Each VM
resource "azurerm_key_vault_key" "key_vault_key" {
  key_vault_id = azurerm_key_vault.kv.id
  count        = var.vm_count
  name         = "${var.project_name}-${var.environment}-${format("%02d", count.index + 1)}-key"
  key_type     = "RSA"
  key_size     = "2048"
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

}

resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

#Creates Admin Credentials for Each VM Saving the Result in Key Vault.
resource "azurerm_key_vault_secret" "vm_admin" {
  name         = "${var.project_name}-${var.environment}-ssh-key"
  value        = tls_private_key.vm_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
}
