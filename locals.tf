# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Landing FQDNs
  landing_fqdn = "${var.landing_subdomain}.${var.domain_name}"

  landing_additional_fqdns = [
    for s in var.landing_additional_subdomains : "${s}.${var.domain_name}"
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
