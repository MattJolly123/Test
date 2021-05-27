variable "project_name" {
  description = "Common project name"
  type        = string
}

variable "environment" {
  description = "Common environment name"
  type        = string
}

variable "location" {
  description = "Region to deploy resources in"
  type        = string
}

variable "subnet_id" {
  description = "The subnet to deploy the virtual machines in"
  type        = string
}

variable "vm_count" {
  description = "How many machines deploy, defaults to 1, anything above one will deploy a HA configuration"
  type        = number
  default     = 1
}

variable "disk_performance_tier" {
  description = "The performance tier of disk to provision"
  type        = string
  default     = "Premium_LRS"
}

variable "vm_size" {
  description = "The size/pricing tier to deploy Virtual Machine as, at least 2GB memory is required for Disk Encryption"
  type        = string
  default     = "Standard_B2ms"
}

variable "delete_os_disk_on_termination" {
  default     = "true"
  description = "When true the OS Disk is deleted upon termination of the Virtual Machine Resource"
}

variable "delete_data_disk_on_termination" {
  default     = "true"
  description = "When true the Data Disks are deleted upon termination of the Virtual Machine Resource"
}

variable "ip_address" {
  description = "The static IP address(es) to assign to the VM(s) PLEASE NOTE: Licences are tied to this value"
  type        = string
  default     = ""
}

variable "public_ip" {
  description = "The static public IP address(es) to assign to the vm(s), these can be assigned for troubleshooting purposes but are not reccomended"
  type        = string
  default     = ""
}

variable "storage_image_id" {
  description = "Virtual Machine source image information. See https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html#storage_image_reference"
  type        = map(string)

  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "os_disk_size_gb" {
  description = "Specifies the size of the OS disk in gigabytes"
  type        = string
  default     = 128
}

variable "additional_disk_size_gb" {
  description = "Specifies the size of the additional disk in gigabytes"
  type        = string
  default     = 64
}

variable "resource_group_name" {
  type = string
}

variable "storage_image_id" {}

variable "kv_resource_group_name" {}
variable "kv_location" {}

variable "workspace_rid" {}


