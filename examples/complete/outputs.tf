output "evilginx_fqdns" {
  description = "All FQDNs routed to the Evilginx VM."
  value       = module.phishsim.evilginx_fqdns
}

output "evilginx_public_ip" {
  description = "Public IP address of the Evilginx VM."
  value       = module.phishsim.evilginx_public_ip
}

output "evilginx_vm_principal_id" {
  description = "System-assigned managed identity principal ID for the Evilginx VM (null when enable_evilginx_managed_identity is false)."
  value       = module.phishsim.evilginx_vm_principal_id
}

output "gophish_private_ip" {
  description = "Private IP address of the Gophish VM."
  value       = module.phishsim.gophish_private_ip
}

output "gophish_public_ip" {
  description = "Public IP address of the Gophish VM."
  value       = module.phishsim.gophish_public_ip
}

output "gophish_vm_principal_id" {
  description = "System-assigned managed identity principal ID for the Gophish VM (null when enable_gophish_managed_identity is false)."
  value       = module.phishsim.gophish_vm_principal_id
}

output "landing_fqdn" {
  description = "Primary FQDN of the landing web server."
  value       = module.phishsim.landing_fqdn
}

output "landing_fqdns" {
  description = "All landing FQDNs routed to the landing web server."
  value       = module.phishsim.landing_fqdns
}

output "landing_public_ip" {
  description = "Public IP address of the landing web VM."
  value       = module.phishsim.landing_public_ip
}

output "landing_url" {
  description = "HTTPS URL of the landing web page."
  value       = module.phishsim.landing_url
}

output "landing_vm_principal_id" {
  description = "System-assigned managed identity principal ID for the landing web VM."
  value       = module.phishsim.landing_vm_principal_id
}
