# -----------------------------------------------------------------------------
# Example: Complete deployment of the Red Team phishing module
# -----------------------------------------------------------------------------
# Usage:
#   cd examples/complete
#   cp terraform.tfvars.example terraform.tfvars
#   # edit terraform.tfvars with your values
#   terraform init
#   terraform plan
#   terraform apply
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.60"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# -----------------------
# Required example inputs
# -----------------------

variable "domain_name" {
  description = "Base domain managed in Cloudflare (e.g. example.com)."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content for VM login."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH and restricted admin access."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for domain_name."
  type        = string
}

variable "cloudflare_api_token" {
  description = "Scoped Cloudflare API token used by the Cloudflare provider."
  type        = string
  sensitive   = true
}

variable "landing_cloudflare_api_token_secret_uri" {
  description = "Key Vault secret URI containing the Cloudflare API token for certbot on the landing VM."
  type        = string
}

variable "certbot_email" {
  description = "Let's Encrypt account email for landing certificate issuance."
  type        = string
}

# -----------------------
# Optional example inputs
# -----------------------

variable "landing_subdomain" {
  description = "Landing page subdomain label."
  type        = string
  default     = "landing"
}

variable "landing_additional_subdomains" {
  description = "Additional landing subdomains (relative to domain_name) routed to the landing VM."
  type        = list(string)
  default     = []
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

variable "location" {
  description = "Azure region."
  type        = string
  default     = "East US"
}

variable "cloudflare_api_token_key_vault_id" {
  description = "Key Vault resource ID for automatic Key Vault Secrets User role assignment to the landing VM identity."
  type        = string
  default     = null
}

variable "assign_key_vault_role_to_landing_vm" {
  description = "When true, assign Key Vault Secrets User on cloudflare_api_token_key_vault_id to the landing VM identity."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "rg-redteam-phishing"
}

variable "admin_username" {
  description = "VM admin username."
  type        = string
  default     = "azureadmin"
}

variable "evilginx_vm_size" {
  description = "Evilginx VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "gophish_vm_size" {
  description = "Gophish VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "landing_vm_size" {
  description = "Landing web VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "ubuntu_image_version" {
  description = "Pinned Ubuntu image version."
  type        = string
  default     = "22.04.202501150"
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

variable "restrict_outbound_traffic" {
  description = "Enable explicit egress allow rules + deny-all baseline in NSGs."
  type        = bool
  default     = true
}

variable "cloudflare_dns_allow_overwrite" {
  description = "Allow Cloudflare records managed by this module to overwrite existing records."
  type        = bool
  default     = false
}

variable "create_wildcard_evilginx_record" {
  description = "Create wildcard Cloudflare A record (*.domain_name) for Evilginx."
  type        = bool
  default     = false
}

variable "evilginx_repo_ref" {
  description = "Pinned Evilginx source ref."
  type        = string
  default     = "30f20165749a5996d46a35b820b41c33a830327b"
}

variable "go_version" {
  description = "Go version installed in cloud-init before building Evilginx and Gophish."
  type        = string
  default     = "1.22.5"
}

variable "go_linux_amd64_tarball_sha256" {
  description = "Expected SHA256 checksum for the Go Linux amd64 tarball."
  type        = string
  default     = "904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0"
}

variable "gophish_repo_ref" {
  description = "Pinned Gophish source ref."
  type        = string
  default     = "f88b204ee4f266bc7df6c6b954abf7b2e8afc22c"
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

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace resource ID for NSG diagnostics."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "redteam"
}

variable "vnet_address_space" {
  description = "Virtual network address space."
  type        = list(string)
  default     = ["10.0.0.0/16"]
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
    Owner      = "RedTeam"
    CostCenter = "Security"
  }
}

locals {
  landing_site_dir_abs = var.landing_site_dir == null ? null : abspath(var.landing_site_dir)
  landing_site_files_base64_from_dir = var.landing_site_dir == null ? {} : {
    for rel in fileset(local.landing_site_dir_abs, "**") :
    rel => filebase64("${local.landing_site_dir_abs}/${rel}")
  }
  landing_site_files_base64_effective = length(var.landing_site_files_base64) > 0 ? var.landing_site_files_base64 : local.landing_site_files_base64_from_dir
}

module "redteam" {
  source = "../../"

  domain_name                             = var.domain_name
  ssh_public_key                          = var.ssh_public_key
  allowed_ssh_cidr                        = var.allowed_ssh_cidr
  cloudflare_zone_id                      = var.cloudflare_zone_id
  cloudflare_api_token                    = var.cloudflare_api_token
  certbot_email                           = var.certbot_email
  landing_cloudflare_api_token_secret_uri = var.landing_cloudflare_api_token_secret_uri
  landing_subdomain                       = var.landing_subdomain
  landing_additional_subdomains           = var.landing_additional_subdomains
  landing_site_files_base64               = local.landing_site_files_base64_effective

  location                            = var.location
  cloudflare_api_token_key_vault_id   = var.cloudflare_api_token_key_vault_id
  assign_key_vault_role_to_landing_vm = var.assign_key_vault_role_to_landing_vm
  resource_group_name                 = var.resource_group_name
  prefix                              = var.prefix
  admin_username                      = var.admin_username
  evilginx_vm_size                    = var.evilginx_vm_size
  gophish_vm_size                     = var.gophish_vm_size
  landing_vm_size                     = var.landing_vm_size
  landing_cloudflare_proxied          = var.landing_cloudflare_proxied
  restrict_outbound_traffic           = var.restrict_outbound_traffic
  cloudflare_dns_allow_overwrite      = var.cloudflare_dns_allow_overwrite
  create_wildcard_evilginx_record     = var.create_wildcard_evilginx_record
  enable_evilginx_managed_identity    = var.enable_evilginx_managed_identity
  enable_gophish_managed_identity     = var.enable_gophish_managed_identity
  log_analytics_workspace_id          = var.log_analytics_workspace_id
  vnet_address_space                  = var.vnet_address_space
  subnet_address_prefix               = var.subnet_address_prefix
  ubuntu_image_version                = var.ubuntu_image_version

  evilginx_repo_ref             = var.evilginx_repo_ref
  gophish_repo_ref              = var.gophish_repo_ref
  go_version                    = var.go_version
  go_linux_amd64_tarball_sha256 = var.go_linux_amd64_tarball_sha256

  landing_page_html = var.landing_page_html

  tags = var.tags
}

output "evilginx_public_ip" {
  value = module.redteam.evilginx_public_ip
}

output "gophish_public_ip" {
  value = module.redteam.gophish_public_ip
}

output "landing_fqdn" {
  value = module.redteam.landing_fqdn
}

output "landing_fqdns" {
  value = module.redteam.landing_fqdns
}

output "landing_public_ip" {
  value = module.redteam.landing_public_ip
}

output "landing_url" {
  value = module.redteam.landing_url
}

output "evilginx_vm_principal_id" {
  value = module.redteam.evilginx_vm_principal_id
}

output "gophish_vm_principal_id" {
  value = module.redteam.gophish_vm_principal_id
}

output "landing_vm_principal_id" {
  value = module.redteam.landing_vm_principal_id
}
