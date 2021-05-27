# client specific
project_name        = ""
storage_client_name = ""
tenants_name        = ""
tenants_id          = ""

#Path to the packer image created - this will install dontnetcore on all vm's created
storage_image_id = "/subscriptions//resourceGroups//providers/Microsoft.Compute/images/"

# Shared variables
environment     = "test"
location        = ""
subscription_id = ""

use_ad_auth   = ""
ad_admin_name = ""
edition       = ""

key_vault_id  = ""
key_vault_uri = ""

# Network variables

network_base_cidr = [""]

subnets = [

  { "name" = ""

    address_space = ""

  endpoints = [] }
]

network_security_group_name = ""

kv_resource_group_name = ""
resource_group_name    = ""

#Setting number of VM's to create - this will enable us to scale vm's
vm_count = 1

