#Resource Group creation
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

#VNET Creation
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.project_name}-vnet-${var.environment}"
  address_space       = var.base_cidr
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    project_name = var.project_name
    environment  = var.environment
    source       = "TERRAFORM"
  }
}

#Subnet creation
resource "azurerm_subnet" "subnet" {
  name                 = lookup(element(var.subnets, count.index), "name", "")
  count                = length(var.subnets)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefix       = lookup(element(var.subnets, count.index), "address_space", "")
  depends_on           = [azurerm_virtual_network.virtual_network]
  service_endpoints    = lookup(element(var.subnets, count.index), "endpoints", "")

  dynamic "delegation" {
    for_each = lookup(element(var.subnets, count.index), "delegation_name", "") == "" ? [] : [1]
    content {
      name = lookup(element(var.subnets, count.index), "name", "")

      service_delegation {
        name    = lookup(element(var.subnets, count.index), "delegation_name", "")
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

#Adding inbound rule for LB:
resource "azurerm_network_security_group" "subnet_security" {
  name                = lookup(element(var.subnets, count.index), "name", "")
  location            = var.location
  resource_group_name = var.resource_group_name
  count               = length(var.subnets)

  security_rule {
    name                       = "LB_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = azurerm_public_ip.lb.ip_address
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  tags = {
    project_name = var.project_name
    environment  = var.environment
    source       = "TERRAFORM"
  }
  depends_on = [azurerm_virtual_network.virtual_network]
}

#SG association to subnet
resource "azurerm_subnet_network_security_group_association" "subnet" {
  count                     = length(var.subnets)
  subnet_id                 = element(azurerm_subnet.subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.subnet_security.*.id, count.index)
  depends_on                = [azurerm_network_security_group.subnet_security, azurerm_subnet.subnet]
}

#Public IP for Load Balancer
resource "azurerm_public_ip" "lb_ip" {
  name                = "${var.project_name}-lb-${var.environment}-publicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

#Load balancer
resource "azurerm_lb" "load_balancer" {
  name                = "${var.project_name}-lb-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "LBPublicIPAddress-${var.environment}"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
    subnet_id            = element(azurerm_subnet.subnet.*.id, count.index)
  }
}

#Load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "${var.project_name}-${var.environment}-lb-backendPool"
}

#Adding VM NICS to Load Balancer backend pool
resource "azurerm_network_interface_backend_address_pool_association" "lb_backend" {
  count                   = var.vm_count
  network_interface_id    = module.vm_module.vm_nic_ids[count.index]
  ip_configuration_name   = "${var.project_name}-${var.environment}-${format("%02d", count.index + 1)}-backend"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}

