# -----------------------------------------------------------------------------
# Input Variables
# -----------------------------------------------------------------------------

variable "admin_username" {
  description = "Admin username for SSH access on all VMs."
  type        = string
  default     = "azureadmin"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the VMs and access the Gophish admin port."
  type        = string

  validation {
    condition = (
      can(cidrhost(var.allowed_ssh_cidr, 0)) &&
      var.allowed_ssh_cidr != "0.0.0.0/0" &&
      can(tonumber(split("/", var.allowed_ssh_cidr)[1])) &&
      tonumber(split("/", var.allowed_ssh_cidr)[1]) >= 24
    )
    error_message = "allowed_ssh_cidr must be a valid CIDR, must not be 0.0.0.0/0, and must be /24 or narrower (for example 203.0.113.10/32)."
  }
}

variable "certbot_email" {
  description = "Email address used to register with Let's Encrypt for landing page certificates."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.certbot_email))
    error_message = "certbot_email must be a valid email address."
  }
}

variable "cloudflare_api_token" {
  description = "Scoped Cloudflare API token used by the Cloudflare provider in the root module. Prefer setting via CLOUDFLARE_API_TOKEN in the root module."
  type        = string
  sensitive   = true
  default     = null
  nullable    = true
}

variable "cloudflare_api_token_key_vault_id" {
  description = "Optional Azure Key Vault resource ID that stores the Cloudflare API token secret. When set with assign_key_vault_role_to_landing_vm=true, Terraform grants the landing VM identity Key Vault Secrets User on this vault."
  type        = string
  default     = null

  validation {
    condition = (
      var.cloudflare_api_token_key_vault_id == null ||
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+$", var.cloudflare_api_token_key_vault_id))
    )
    error_message = "cloudflare_api_token_key_vault_id must be null or a valid Key Vault resource ID."
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for domain_name."
  type        = string

  validation {
    condition     = length(trimspace(var.cloudflare_zone_id)) > 0
    error_message = "cloudflare_zone_id must not be empty."
  }
}

variable "domain_name" {
  description = "The base domain name (e.g. example.com). Cloudflare DNS records are managed for this domain."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "domain_name must be a valid domain (e.g. example.com)."
  }
}

variable "evilginx_repo_ref" {
  description = "Git ref (branch, tag, or commit SHA) to check out when building Evilginx from source."
  type        = string
  default     = "30f20165749a5996d46a35b820b41c33a830327b"

  validation {
    condition = (
      can(regex("^[A-Za-z0-9._/-]{1,128}$", var.evilginx_repo_ref)) &&
      !can(regex("\\.\\.", var.evilginx_repo_ref))
    )
    error_message = "evilginx_repo_ref must contain only git-safe characters and must not include '..'."
  }
}

variable "evilginx_vm_size" {
  description = "Azure VM size/SKU for the Evilginx VM."
  type        = string
  default     = "Standard_B2s"
}

variable "gophish_repo_ref" {
  description = "Git ref (branch, tag, or commit SHA) to check out when building Gophish from source."
  type        = string
  default     = "f88b204ee4f266bc7df6c6b954abf7b2e8afc22c"

  validation {
    condition = (
      can(regex("^[A-Za-z0-9._/-]{1,128}$", var.gophish_repo_ref)) &&
      !can(regex("\\.\\.", var.gophish_repo_ref))
    )
    error_message = "gophish_repo_ref must contain only git-safe characters and must not include '..'."
  }
}

variable "go_linux_amd64_tarball_sha256" {
  description = "Expected SHA256 checksum for the Go Linux amd64 tarball used in cloud-init."
  type        = string
  default     = "904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0"

  validation {
    condition     = can(regex("^[a-f0-9]{64}$", var.go_linux_amd64_tarball_sha256))
    error_message = "go_linux_amd64_tarball_sha256 must be a 64-character lowercase hex SHA256 digest."
  }
}

variable "go_version" {
  description = "Go version installed by cloud-init before building Evilginx and Gophish."
  type        = string
  default     = "1.22.5"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.go_version))
    error_message = "go_version must use semantic version format, for example 1.22.5."
  }
}

variable "gophish_vm_size" {
  description = "Azure VM size/SKU for the Gophish VM."
  type        = string
  default     = "Standard_B2s"
}

variable "landing_additional_subdomains" {
  description = "Additional landing subdomains (relative to domain_name) that should route to the landing VM and be included on the TLS certificate."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for s in var.landing_additional_subdomains :
      can(regex("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)*$", s)) && !can(regex("[*@]", s))
    ])
    error_message = "Each landing_additional_subdomains entry must be a valid subdomain name and must not contain '*' or '@'."
  }

  validation {
    condition     = length(distinct(var.landing_additional_subdomains)) == length(var.landing_additional_subdomains)
    error_message = "landing_additional_subdomains must not contain duplicates."
  }
}

variable "landing_cloudflare_api_token_secret_uri" {
  description = "Azure Key Vault secret URI containing the Cloudflare DNS API token used by certbot on the landing VM (for example https://myvault.vault.azure.net/secrets/cloudflare-token/<version>)."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^https://[a-zA-Z0-9-]+\\.vault\\.azure\\.net/secrets/[a-zA-Z0-9-]+(?:/[a-fA-F0-9]{32})?$", var.landing_cloudflare_api_token_secret_uri))
    error_message = "landing_cloudflare_api_token_secret_uri must be a valid Azure Key Vault secret URI."
  }
}

variable "landing_cloudflare_proxied" {
  description = "Whether the landing subdomain records should be proxied through Cloudflare."
  type        = bool
  default     = true
}

variable "landing_page_html" {
  description = "HTML content served as /index.html on the landing VM."
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

variable "landing_site_files_base64" {
  description = "Optional map of landing site files to write under /var/www/landing where each key is a relative path (for example index.html or assets/logo.png) and each value is base64-encoded file content. When unset, landing_page_html is written to /var/www/landing/index.html."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for p in keys(var.landing_site_files_base64) :
      !startswith(p, "/") &&
      !contains(split("/", p), "..") &&
      trimspace(p) != "" &&
      !endswith(p, "/")
    ])
    error_message = "landing_site_files_base64 keys must be non-empty relative file paths and must not contain '..' path segments."
  }

  validation {
    condition = (
      length(var.landing_site_files_base64) == 0 ||
      contains(keys(var.landing_site_files_base64), "index.html")
    )
    error_message = "landing_site_files_base64 must include index.html when provided."
  }

  validation {
    condition = alltrue([
      for c in values(var.landing_site_files_base64) :
      can(base64decode(c))
    ])
    error_message = "Each landing_site_files_base64 value must be valid base64 content."
  }
}

variable "landing_subdomain" {
  description = "Subdomain name for the landing page (relative to domain_name)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)*$", var.landing_subdomain))
    error_message = "landing_subdomain must be a valid subdomain name (lowercase letters, numbers, hyphens, and dots only)."
  }
}

variable "landing_vm_size" {
  description = "Azure VM size/SKU for the landing web VM."
  type        = string
  default     = "Standard_B2s"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "East US"
}

variable "assign_key_vault_role_to_landing_vm" {
  description = "When true, assigns Key Vault Secrets User on cloudflare_api_token_key_vault_id to the landing VM managed identity."
  type        = bool
  default     = true

  validation {
    condition = (
      !var.assign_key_vault_role_to_landing_vm ||
      var.cloudflare_api_token_key_vault_id != null
    )
    error_message = "cloudflare_api_token_key_vault_id must be set when assign_key_vault_role_to_landing_vm is true."
  }
}

variable "enable_evilginx_managed_identity" {
  description = "Enable a system-assigned managed identity on the Evilginx VM."
  type        = bool
  default     = false
}

variable "enable_gophish_managed_identity" {
  description = "Enable a system-assigned managed identity on the Gophish VM."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace resource ID for NSG diagnostics."
  type        = string
  default     = null

  validation {
    condition = (
      var.log_analytics_workspace_id == null ||
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be null or a valid Log Analytics workspace resource ID."
  }
}

variable "prefix" {
  description = "Prefix to append to resource names for uniqueness."
  type        = string
  default     = "redteam"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.prefix))
    error_message = "prefix must be 1-20 characters using lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group."
  type        = string
  default     = "rg-redteam-phishing"
}

variable "restrict_outbound_traffic" {
  description = "When true, NSGs enforce explicit egress allow rules and a deny-all outbound baseline."
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "The SSH public key content used for authenticating to all VMs."
  type        = string
  sensitive   = true
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]

  validation {
    condition     = alltrue([for c in var.subnet_address_prefix : can(cidrhost(c, 0))])
    error_message = "Each subnet_address_prefix entry must be a valid CIDR."
  }
}

variable "tags" {
  description = "Additional tags to merge with the default module tags on all resources."
  type        = map(string)
  default     = {}
}

variable "ubuntu_image_version" {
  description = "Pinned Ubuntu image version for VMs. Do not use 'latest' in pre-production or production."
  type        = string

  validation {
    condition     = length(trimspace(var.ubuntu_image_version)) > 0 && lower(trimspace(var.ubuntu_image_version)) != "latest"
    error_message = "ubuntu_image_version must be a specific pinned image version and must not be 'latest'."
  }
}

variable "cloudflare_dns_allow_overwrite" {
  description = "Whether Cloudflare DNS records managed by this module are allowed to overwrite existing records."
  type        = bool
  default     = false
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = alltrue([for c in var.vnet_address_space : can(cidrhost(c, 0))])
    error_message = "Each vnet_address_space entry must be a valid CIDR."
  }
}
