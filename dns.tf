# =============================================================================
# Cloudflare DNS Records
# =============================================================================

# Root (@) A record -> Evilginx public IP
resource "cloudflare_record" "root" {
  zone_id         = var.cloudflare_zone_id
  name            = var.domain_name
  type            = "A"
  value           = azurerm_public_ip.evilginx.ip_address
  ttl             = 1
  proxied         = false
  allow_overwrite = var.cloudflare_dns_allow_overwrite
}

# Wildcard (*) A record -> Evilginx public IP
resource "cloudflare_record" "wildcard" {
  count           = var.create_wildcard_evilginx_record ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "*.${var.domain_name}"
  type            = "A"
  value           = azurerm_public_ip.evilginx.ip_address
  ttl             = 1
  proxied         = false
  allow_overwrite = var.cloudflare_dns_allow_overwrite
}

# Landing subdomain A records -> Landing VM public IP
resource "cloudflare_record" "landing_subdomains" {
  for_each = toset(local.landing_all_fqdns)

  zone_id         = var.cloudflare_zone_id
  name            = each.value
  type            = "A"
  value           = azurerm_public_ip.landing.ip_address
  ttl             = 1
  proxied         = var.landing_cloudflare_proxied
  allow_overwrite = var.cloudflare_dns_allow_overwrite
}
