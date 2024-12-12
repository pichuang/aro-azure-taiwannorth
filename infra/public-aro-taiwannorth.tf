# https://registry.terraform.io/providers/hashicorp/azurerm/3.117.0/docs/resources/redhat_openshift_cluster
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.117.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.53.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "= 2.5.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "= 3.6.3"
    }
  }
  required_version = "< 1.6"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
}

#
# Azure Resource Provider
#
# One Time

# locals {
#   resource_providers = [
#     "Microsoft.RedHatOpenShift",
#     "Microsoft.Compute",
#     "Microsoft.Storage",
#     "Microsoft.Authorization",
#   ]

#   provider_map = { for provider in local.resource_providers : provider => provider }
# }

# resource "azurerm_resource_provider_registration" "provider" {
#   for_each = local.provider_map
#   name     = each.value
# }

#
# Secret
#

# data "azurerm_client_config" "example" {}

# data "azuread_client_config" "example" {}

data "local_sensitive_file" "redhatopenshit_pull_secret" {
  filename = var.redhatopenshit_pull_secret
}

#
# Service Principal
#

resource "azuread_application" "application-aro" {
  display_name = var.service_principal_client_name
}

resource "azuread_service_principal" "sp-aro" {
  client_id = azuread_application.application-aro.client_id
}

resource "azuread_service_principal_password" "spp-aro" {
  service_principal_id = azuread_service_principal.sp-aro.object_id
}

resource "azurerm_role_assignment" "assign-sp-role-to-vnet-aro" {
  scope                = azurerm_virtual_network.vnet-aro.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.sp-aro.object_id
}

# resource "azurerm_role_assignment" "assign-sp-role-to-rt" {
#   scope                = azurerm_route_table.rt-for-aro.id
#   role_definition_name = "Network Contributor"
#   principal_id         = azuread_service_principal.sp-aro.object_id
# }

# resource "azurerm_role_assignment" "assign-sp-role-to-private-dns" {
#   scope                = azurerm_private_dns_zone.private-dns.id
#   role_definition_name = "Private DNS Zone Contributor"
#   principal_id         = azuread_service_principal.sp-aro.object_id
# }

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  client_id = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
}


# resource "azurerm_role_assignment" "assign-rp-role-to-rt" {
#   scope                = azurerm_route_table.rt-for-aro.id
#   role_definition_name = "Network Contributor"
#   principal_id         = data.azuread_service_principal.redhatopenshift.object_id
# }

resource "azurerm_role_assignment" "assign-rp-role-to-vnet-aro" {
  scope                = azurerm_virtual_network.vnet-aro.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}

#
# Azure Resource Group
#

resource "random_id" "resource_group_id" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg-aro" {
  # name     = "rg-aro-${lower(random_id.resource_group_id.hex)}"
  name     = var.aro_resource_group_name
  location = var.location

  tags = {
    "CreateDate" = timestamp()
    "Purpose"    = "ARO Taiwan North"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

#
# Azure Virtual Network
#

resource "azurerm_virtual_network" "vnet-aro" {
  name                = var.vnet_aro_name
  address_space       = [var.vnet_aro_address_space]
  location            = azurerm_resource_group.rg-aro.location
  resource_group_name = azurerm_resource_group.rg-aro.name

  depends_on = [
    azurerm_resource_group.rg-aro,
  ]

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_subnet" "subnet-aro-master" {
  name                 = var.subnet_aro_master_name
  resource_group_name  = azurerm_resource_group.rg-aro.name
  virtual_network_name = azurerm_virtual_network.vnet-aro.name
  address_prefixes     = [var.subnet_aro_master_address_prefixes]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]


}

resource "azurerm_subnet" "subnet-aro-worker" {
  name                 = var.subnet_aro_worker_name
  resource_group_name  = azurerm_resource_group.rg-aro.name
  virtual_network_name = azurerm_virtual_network.vnet-aro.name
  address_prefixes     = [var.subnet_aro_worker_address_prefixes]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "subnet-jump" {
  name                 = var.subnet_jump_name
  resource_group_name  = azurerm_resource_group.rg-aro.name
  virtual_network_name = azurerm_virtual_network.vnet-aro.name
  address_prefixes     = [var.subnet_jump_address_prefixes]
}


resource "azurerm_subnet" "subnet-pep" {
  name                 = var.subnet_pep_name
  resource_group_name  = azurerm_resource_group.rg-aro.name
  virtual_network_name = azurerm_virtual_network.vnet-aro.name
  address_prefixes     = [var.subnet_pep_address_prefixes]
}

#
# VNet Peering
#

# resource "azurerm_virtual_network_peering" "peering-aro-to-hub" {
#   name                 = "peering-aro-to-hub"
#   resource_group_name  = azurerm_resource_group.rg-aro.name
#   virtual_network_name = azurerm_virtual_network.vnet-aro.name
#   #XXX
#   remote_virtual_network_id    = "/subscriptions/82c65997-b2ba-41ef-bf8a-80bc639ea78d/resourceGroups/rg-hub-eastus2/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus2"
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = true
#   use_remote_gateways          = true
# }

# resource "azurerm_virtual_network_peering" "peering-hub-to-aro" {
#   name                         = "peering-hub-to-aro"
#   resource_group_name          = azurerm_resource_group.example.name
#   virtual_network_name         = azurerm_virtual_network.example-1.name
#   remote_virtual_network_id    = azurerm_virtual_network.vnet-aro.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = true
#   use_remote_gateways          = false
# }

#
# Azure Route Table
#

# resource "azurerm_route_table" "rt-for-aro" {
#   name                          = "rt-for-aro"
#   location                      = azurerm_resource_group.rg-aro.location
#   resource_group_name           = azurerm_resource_group.rg-aro.name
#   bgp_route_propagation_enabled = false

#   dynamic "route" {
#     for_each = var.udr_enable ? [1] : []

#     content {
#       name                   = "rt-to-aro"
#       address_prefix         = "0.0.0.0/0"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = var.afw_private_ip # Azure Firewall Private IP
#     }
#   }
# }

# resource "azurerm_subnet_route_table_association" "rt-assoc-for-subnet-aro-master" {
#   count         = var.udr_enable ? 1 : 0
#   subnet_id     = azurerm_subnet.subnet-aro-master.id
#   route_table_id = azurerm_route_table.rt-for-aro.id
# }

# resource "azurerm_subnet_route_table_association" "rt-assoc-for-subnet-aro-worker" {
#   count         = var.udr_enable ? 1 : 0
#   subnet_id     = azurerm_subnet.subnet-aro-worker.id
#   route_table_id = azurerm_route_table.rt-for-aro.id
# }

#
# Azure Private DNS Zone
#

# resource "azurerm_private_dns_zone" "private-dns" {
#   name                = var.aro_dns_zone_name
#   resource_group_name = azurerm_resource_group.rg-aro.name

#   lifecycle {
#     ignore_changes = [
#       tags
#     ]
#   }
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "vnlink-to-vnet-aro" {
#   name                  = "vnlink-to-vnet-aro"
#   resource_group_name   = azurerm_resource_group.rg-aro.name
#   private_dns_zone_name = azurerm_private_dns_zone.private-dns.name
#   virtual_network_id    = azurerm_virtual_network.vnet-aro.id
#   registration_enabled  = true
# }

# resource "azurerm_private_dns_a_record" "pnds-a-api" {
#   name                = "api"
#   zone_name           = azurerm_private_dns_zone.private-dns.name
#   resource_group_name = azurerm_resource_group.rg-aro.name
#   ttl                 = 3600

#   records    = [var.aro_api_private_ip]
#   depends_on = [azurerm_private_dns_zone.private-dns]
# }

# resource "azurerm_private_dns_a_record" "pnds-a-ingress" {
#   name                = "*.apps"
#   zone_name           = azurerm_private_dns_zone.private-dns.name
#   resource_group_name = azurerm_resource_group.rg-aro.name
#   ttl                 = 3600

#   records    = [var.aro_ingress_private_ip]
#   depends_on = [azurerm_private_dns_zone.private-dns]
# }

#
# Azure Red Hat OpenShift
#

# https://registry.terraform.io/providers/hashicorp/azurerm/3.117.0/docs/resources/redhat_openshift_cluster
resource "azurerm_redhat_openshift_cluster" "aro-instance" {
  name                = var.aro_cluster_name
  location            = azurerm_resource_group.rg-aro.location
  resource_group_name = azurerm_resource_group.rg-aro.name

  cluster_profile {
    domain = var.aro_dns_zone_name
    # https://learn.microsoft.com/en-us/azure/openshift/support-lifecycle#azure-red-hat-openshift-release-calendar
    # az aro get-versions --location taiwannorth
    # 2024-12-11
    # "4.12.25",
    # "4.12.60",
    # "4.13.40",
    # "4.14.16",
    # "4.15.27"
    version                     = var.aro_cluster_version
    fips_enabled                = false
    pull_secret                 = data.local_sensitive_file.redhatopenshit_pull_secret.content
    managed_resource_group_name = "rg-mgmt-aro-${var.aro_cluster_name}"
  }

  network_profile {
    pod_cidr                                     = var.aro_pod_cidr
    service_cidr                                 = var.aro_service_cidr
    outbound_type                                = var.udr_enable ? "UserDefinedRouting" : "Loadbalancer"
    preconfigured_network_security_group_enabled = false
  }

  main_profile {
    vm_size                    = var.aro_master_vm_size
    subnet_id                  = azurerm_subnet.subnet-aro-master.id
    encryption_at_host_enabled = true
  }

  worker_profile {
    vm_size                    = var.aro_worker_vm_size
    disk_size_gb               = 128
    node_count                 = 3
    subnet_id                  = azurerm_subnet.subnet-aro-worker.id
    encryption_at_host_enabled = true
  }

  api_server_profile {
    visibility = var.aro_api_visibility
  }

  ingress_profile {
    visibility = var.aro_ingress_visibility
  }

  service_principal {
    client_id     = azuread_application.application-aro.client_id
    client_secret = azuread_service_principal_password.spp-aro.value
  }

  depends_on = [
    azurerm_role_assignment.assign-rp-role-to-vnet-aro,
    # azurerm_role_assignment.assign-rp-role-to-rt,
    # azurerm_role_assignment.assign-sp-role-to-private-dns,
    azurerm_role_assignment.assign-sp-role-to-vnet-aro,
    # azurerm_role_assignment.assign-sp-role-to-rt,
  ]

  lifecycle {
    ignore_changes = [
      cluster_profile
    ]
  }
}
