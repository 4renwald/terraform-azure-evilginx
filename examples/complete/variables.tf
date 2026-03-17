variable "admin_username" {
  description = "VM admin username."
  type        = string
  default     = "azureadmin"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH and restricted admin access."
  type        = string
}

variable "assign_key_vault_role_to_landing_vm" {
  description = "When true, assign Key Vault Secrets User on cloudflare_api_token_key_vault_id to the landing VM identity."
  type        = bool
  default     = true
}

variable "certbot_email" {
  description = "Let's Encrypt account email for landing certificate issuance."
  type        = string
}

variable "cloudflare_api_token_key_vault_id" {
  description = "Key Vault resource ID for automatic Key Vault Secrets User role assignment to the landing VM identity."
  type        = string
  default     = null
}

variable "cloudflare_dns_allow_overwrite" {
  description = "Allow Cloudflare records managed by this module to overwrite existing records."
  type        = bool
  default     = false
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for domain_name."
  type        = string
}

variable "create_root_evilginx_record" {
  description = "Create root Cloudflare A record (@ / domain_name) for Evilginx."
  type        = bool
  default     = true
}

variable "create_wildcard_evilginx_record" {
  description = "Create wildcard Cloudflare A record (*.domain_name) for Evilginx."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Base domain managed in Cloudflare (e.g. example.com)."
  type        = string
}

variable "enable_evilginx_managed_identity" {
  description = "Enable a system-assigned managed identity on Evilginx VM."
  type        = bool
  default     = false
}

variable "enable_gophish_managed_identity" {
  description = "Enable a system-assigned managed identity on Gophish VM."
  type        = bool
  default     = false
}

variable "evilginx_additional_subdomains" {
  description = "Additional Evilginx subdomains (relative to domain_name) routed to the Evilginx VM."
  type        = list(string)
  default     = []
}

variable "evilginx_repo_ref" {
  description = "Pinned Evilginx source ref."
  type        = string
  default     = "30f20165749a5996d46a35b820b41c33a830327b"
}

variable "evilginx_vm_size" {
  description = "Evilginx VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "go_linux_amd64_tarball_sha256" {
  description = "Expected SHA256 checksum for the Go Linux amd64 tarball."
  type        = string
  default     = "904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0"
}

variable "go_version" {
  description = "Go version installed in cloud-init before building Evilginx and Gophish."
  type        = string
  default     = "1.22.5"
}

variable "gophish_repo_ref" {
  description = "Pinned Gophish source ref."
  type        = string
  default     = "f88b204ee4f266bc7df6c6b954abf7b2e8afc22c"
}

variable "gophish_vm_size" {
  description = "Gophish VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "landing_additional_subdomains" {
  description = "Additional landing subdomains (relative to domain_name) routed to the landing VM."
  type        = list(string)
  default     = []
}

variable "landing_cloudflare_api_token_secret_uri" {
  description = "Key Vault secret URI containing the Cloudflare API token for certbot on the landing VM."
  type        = string
}

variable "landing_cloudflare_proxied" {
  description = "Whether Cloudflare proxies the landing subdomain."
  type        = bool
  default     = true
}

variable "landing_page_html" {
  description = "Optional inline HTML content for /index.html when no landing site files are supplied."
  type        = string
  default     = <<-EOT
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Landing Page</title>
      </head>
      <body>
        <h1>Landing Page</h1>
        <p>This landing page is online.</p>
      </body>
    </html>
  EOT
}

variable "landing_site_dir" {
  description = "Optional path to a local landing site directory (for example containing index.html and assets/). Files are uploaded to /var/www/landing."
  type        = string
  default     = null
}

variable "landing_site_files_base64" {
  description = "Optional explicit map of relative landing site file paths to base64 content (advanced override)."
  type        = map(string)
  default     = {}
}

variable "landing_subdomain" {
  description = "Landing page subdomain label."
  type        = string
  default     = "landing"
}

variable "landing_subdomains" {
  description = "Optional complete list of landing subdomains (relative to domain_name)."
  type        = list(string)
  default     = []
}

variable "landing_vm_size" {
  description = "Landing web VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "East US"
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace resource ID for NSG diagnostics."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "phishsim"
}

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "rg-phishsim"
}

variable "restrict_outbound_traffic" {
  description = "Enable explicit egress allow rules + deny-all baseline in NSGs."
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key content for VM login."
  type        = string
}

variable "subnet_address_prefix" {
  description = "Subnet address prefix list."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    CostCenter = "Security"
    Owner      = "PhishingSim"
  }
}

variable "ubuntu_image_version" {
  description = "Pinned Ubuntu image version."
  type        = string
  default     = "22.04.202501150"
}

variable "vnet_address_space" {
  description = "Virtual network address space."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
