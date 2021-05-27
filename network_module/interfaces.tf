
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual machine"
}

variable "location" {
  type        = string
  default     = "UK West"
  description = "The region to deploy into"
}

variable "environment" {
  type        = string
  description = "The environment that this resource is in"
}

variable "project_name" {
  type        = string
  description = "Project name for this resource"
}

variable "base_cidr" {
  type        = list(any)
  default     = ["10.2.0.0/20"]
  description = "The Address Spaces of the Network to Add"
}

variable "subnets" {
  type        = list(any)
  default     = []
  description = "List of subnets with key = Name and value = address space such as 'AzureBastionSubnet' = '10.2.1.0/24'"
}

variable "vm_count" {
  description = "How many machines deploy, defaults to 1, anything above one will deploy a HA configuration"
  type        = number
  default     = 1
}
