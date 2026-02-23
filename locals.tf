# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Evilginx FQDNs
  evilginx_additional_fqdns = [
    for s in var.evilginx_additional_subdomains : "${s}.${var.domain_name}"
  ]
  evilginx_all_fqdns = distinct(concat([var.domain_name], local.evilginx_additional_fqdns))

  # Landing FQDNs
  landing_subdomains_effective = length(var.landing_subdomains) > 0 ? var.landing_subdomains : distinct(concat([var.landing_subdomain], var.landing_additional_subdomains))
  landing_fqdn                 = "${local.landing_subdomains_effective[0]}.${var.domain_name}"

  landing_additional_fqdns = [
    for s in slice(local.landing_subdomains_effective, 1, length(local.landing_subdomains_effective)) : "${s}.${var.domain_name}"
  ]

  landing_all_fqdns = distinct(concat([local.landing_fqdn], local.landing_additional_fqdns))

  # Certbot stores the certificate under the first -d value (primary).
  landing_primary_fqdn        = local.landing_all_fqdns[0]
  landing_server_names        = join(" ", local.landing_all_fqdns)
  landing_certbot_domain_args = join(" ", [for d in local.landing_all_fqdns : "-d ${d}"])

  landing_site_files_base64_effective = length(var.landing_site_files_base64) > 0 ? var.landing_site_files_base64 : {
    "index.html" = base64encode(var.landing_page_html)
  }
  landing_site_file_paths_sorted = sort(keys(local.landing_site_files_base64_effective))
  landing_site_files = [
    for p in local.landing_site_file_paths_sorted : {
      path        = p
      content_b64 = local.landing_site_files_base64_effective[p]
    }
  ]

  common_tags = merge(
    {
      Project     = "RedTeam-PhishingSim"
      ManagedBy   = "Terraform"
      Environment = "Assessment"
    },
    var.tags
  )
}
