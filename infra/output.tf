output "console_url" {
  value = azurerm_redhat_openshift_cluster.aro-instance.console_url
}

output "api_ip_address" {
  value = azurerm_redhat_openshift_cluster.aro-instance.api_server_profile[0].ip_address
}

output "ingress_url" {
  value = azurerm_redhat_openshift_cluster.aro-instance.api_server_profile[0].url
}

output "ingress_ip_address" {
  value = azurerm_redhat_openshift_cluster.aro-instance.ingress_profile[0].ip_address
}