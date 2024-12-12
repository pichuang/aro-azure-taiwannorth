variable "subscription_id" {
  description = "The subscription ID for Azure Red Hat OpenShift"
  type        = string
}

variable "location" {
  description = "The location for the Azure resources"
  type        = string
}

variable "aro_resource_group_name" {
  description = "The name of the resource group for Azure Red Hat OpenShift"
  type        = string
}

variable "aro_cluster_name" {
  description = "The name of the Azure Red Hat OpenShift cluster"
  type        = string
}

variable "redhatopenshit_pull_secret" {
  description = "The file path to the Red Hat pull secret"
  type        = string
}

variable "service_principal_client_name" {
  description = "The name of the service principal client"
  type        = string
}

variable "vnet_aro_name" {
  description = "The name of the virtual network for Azure Red Hat OpenShift"
  type        = string
}

variable "vnet_aro_address_space" {
  description = "The address space for the virtual network for Azure Red Hat OpenShift"
  type        = string
}

variable "subnet_aro_master_name" {
  description = "The name of the subnet for the Azure Red Hat OpenShift master"
  type        = string
}

variable "subnet_aro_master_address_prefixes" {
  description = "The address prefixes for the subnet for the Azure Red Hat OpenShift master"
  type        = string
}

variable "subnet_aro_worker_name" {
  description = "The name of the subnet for the Azure Red Hat OpenShift worker"
  type        = string
}

variable "subnet_aro_worker_address_prefixes" {
  description = "The address prefixes for the subnet for the Azure Red Hat OpenShift worker"
  type        = string
}

variable "subnet_jump_name" {
  description = "The name of the subnet for the Azure Red Hat OpenShift common"
  type        = string
}

variable "subnet_jump_address_prefixes" {
  description = "The address prefixes for the subnet for the Azure Red Hat OpenShift common"
  type        = string
}

# variable "afw_private_ip" {
#   description = "The private IP address of the Azure Firewall"
#   type        = string
# }

variable "aro_dns_zone_name" {
  description = "The name of the private DNS zone for Azure Red Hat OpenShift"
  type        = string
}

# variable "aro_api_private_ip" {
#   description = "The private IP address of the Azure Red Hat OpenShift API"
#   type        = string
# }

# variable "aro_ingress_private_ip" {
#   description = "The private IP address of the Azure Red Hat OpenShift Ingress"
#   type        = string
# }

variable "aro_pod_cidr" {
  description = "The pod CIDR for the Azure Red Hat OpenShift"
  type        = string
}

variable "aro_service_cidr" {
  description = "The service CIDR for the Azure Red Hat OpenShift"
  type        = string
}

variable "aro_master_vm_size" {
  description = "The VM size for the Azure Red Hat OpenShift master"
  type        = string
}

variable "aro_worker_vm_size" {
  description = "The VM size for the Azure Red Hat OpenShift worker"
  type        = string
}

variable "subnet_pep_name" {
  description = "The name of the subnet for the Azure Red Hat OpenShift PEPE"
  type        = string
}

variable "subnet_pep_address_prefixes" {
  description = "The address prefixes for the subnet for the Azure Red Hat OpenShift PEPE"
  type        = string
}

variable "aro_cluster_version" {
  description = "The version of the Azure Red Hat OpenShift cluster"
  type        = string
}

variable "aro_api_visibility" {
  description = "The visibility of the Azure Red Hat OpenShift API"
  type        = string
}

variable "aro_ingress_visibility" {
  description = "The visibility of the Azure Red Hat OpenShift Ingress"
  type        = string
}

variable "udr_enable" {
  description = "The enable of the Azure Red Hat OpenShift UDR"
  type        = bool
}
