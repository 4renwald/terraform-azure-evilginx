# -----------------------------------------------------------------------------
# Output Values (alphabetical order)
# -----------------------------------------------------------------------------

output "evilginx_public_ip" {
  description = "Public IP address of the Evilginx VM."
  value       = azurerm_public_ip.evilginx.ip_address
}

output "evilginx_vm_principal_id" {
  description = "System-assigned managed identity principal ID for the Evilginx VM (null when enable_evilginx_managed_identity is false)."
  value       = try(azurerm_linux_virtual_machine.evilginx.identity[0].principal_id, null)
}

output "gophish_public_ip" {
  description = "Public IP address of the Gophish VM."
  value       = azurerm_public_ip.gophish.ip_address
}

output "gophish_vm_principal_id" {
  description = "System-assigned managed identity principal ID for the Gophish VM (null when enable_gophish_managed_identity is false)."
  value       = try(azurerm_linux_virtual_machine.gophish.identity[0].principal_id, null)
}

output "landing_fqdn" {
  description = "Primary FQDN of the landing web server."
  value       = local.landing_fqdn
}

output "landing_fqdns" {
  description = "All landing FQDNs routed to the landing web server."
  value       = local.landing_all_fqdns
}

output "landing_public_ip" {
  description = "Public IP address of the landing web VM."
  value       = azurerm_public_ip.landing.ip_address
}

output "landing_url" {
  description = "HTTPS URL of the landing web page."
  value       = "https://${local.landing_fqdn}"
}

output "landing_vm_principal_id" {
  description = "System-assigned managed identity principal ID for the landing web VM."
  value       = azurerm_linux_virtual_machine.landing.identity[0].principal_id
}
