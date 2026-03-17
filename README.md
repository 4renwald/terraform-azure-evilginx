# terraform-azure-evilginx

Terraform module that provisions an Azure phishing simulation stack for authorized security assessments. The module creates three Ubuntu virtual machines, wires the required Azure networking and security controls, and manages the corresponding Cloudflare DNS records.

The deployed stack includes:

- an Evilginx VM built from source
- a Gophish VM built from source
- a landing-page VM served by nginx with Let's Encrypt DNS-01 validation through Cloudflare
- a virtual network, subnet, public IPs, NICs, NSGs, and optional NSG diagnostic settings
- an optional Key Vault role assignment that lets the landing VM read the Cloudflare token secret at boot

The repository root is the reusable Terraform module. [`examples/complete`](examples/complete) is the canonical example root for running the module.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | `>= 1.6.0, < 2.0.0` |

## Providers

| Name | Source | Version |
| --- | --- | --- |
| `azurerm` | `hashicorp/azurerm` | `~> 4.60` |
| `cloudflare` | `cloudflare/cloudflare` | `~> 4.0` |

## Modules

This module does not call any child modules.

## Resources

This module manages the following resource types:

- `azurerm_linux_virtual_machine`
- `azurerm_monitor_diagnostic_setting`
- `azurerm_network_interface`
- `azurerm_network_interface_security_group_association`
- `azurerm_network_security_group`
- `azurerm_public_ip`
- `azurerm_resource_group`
- `azurerm_role_assignment`
- `azurerm_subnet`
- `azurerm_virtual_network`
- `cloudflare_record`

## Usage

Configure provider authentication in the caller. The example below assumes:

- Azure authentication is already configured for the AzureRM provider
- `ARM_SUBSCRIPTION_ID` is exported for AzureRM 4.x if it is not set explicitly in the provider
- `CLOUDFLARE_API_TOKEN` is exported for the Cloudflare provider

```bash
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export CLOUDFLARE_API_TOKEN="<cloudflare-api-token>"
```

```hcl
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

provider "cloudflare" {}

module "redteam" {
  source = "github.com/4renwald/terraform-azure-evilginx"

  allowed_ssh_cidr                        = "203.0.113.10/32"
  certbot_email                           = "ops@example.com"
  cloudflare_api_token_key_vault_id       = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault>"
  cloudflare_zone_id                      = "<cloudflare-zone-id>"
  domain_name                             = "example.com"
  evilginx_additional_subdomains          = ["auth", "mail"]
  landing_cloudflare_api_token_secret_uri = "https://<vault>.vault.azure.net/secrets/<secret>/<version>"
  landing_subdomains                      = ["landing", "promo"]
  landing_site_files_base64 = {
    for rel in fileset("${path.module}/landing-site", "**") :
    rel => filebase64("${path.module}/landing-site/${rel}")
  }
  ssh_public_key       = file("~/.ssh/id_ed25519.pub")
  ubuntu_image_version = "22.04.202501150"
}
```

The module is intentionally backend-free. Configure remote state in your caller root if you need it.

## Example

[`examples/complete`](examples/complete) is the supported example root for this module.

```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export CLOUDFLARE_API_TOKEN="<cloudflare-api-token>"
terraform init
terraform plan
terraform apply
```

The example adds one convenience input that is not part of the root module interface:

- `landing_site_dir`: local directory path converted into `landing_site_files_base64`

## Behavior Notes

- `landing_subdomains` takes precedence over `landing_subdomain` and `landing_additional_subdomains` when it is non-empty.
- `landing_site_files_base64` takes precedence over `landing_page_html` when it is non-empty.
- `create_root_evilginx_record` controls the apex/root A record.
- `create_wildcard_evilginx_record` controls the wildcard A record.
- the landing VM always has a system-assigned managed identity
- Evilginx and Gophish managed identities are optional
- `cloudflare_api_token` remains in the module input surface for backward compatibility, but the module itself does not read it

## Inputs

### Required Inputs

| Name | Type | Description |
| --- | --- | --- |
| `allowed_ssh_cidr` | `string` | CIDR block allowed to SSH into the VMs and access the Gophish admin port |
| `certbot_email` | `string` | Email address used to register with Let's Encrypt for landing page certificates |
| `cloudflare_zone_id` | `string` | Cloudflare Zone ID for `domain_name` |
| `domain_name` | `string` | Base domain managed in Cloudflare |
| `landing_cloudflare_api_token_secret_uri` | `string` | Azure Key Vault secret URI containing the Cloudflare token used by certbot on the landing VM |
| `ssh_public_key` | `string` | SSH public key content used for all VMs |
| `ubuntu_image_version` | `string` | Pinned Ubuntu image version |

### Optional Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `admin_username` | `string` | `"azureadmin"` | Admin username for SSH access on all VMs |
| `assign_key_vault_role_to_landing_vm` | `bool` | `true` | Assign `Key Vault Secrets User` on `cloudflare_api_token_key_vault_id` to the landing VM identity |
| `cloudflare_api_token` | `string` | `null` | Backward-compatibility input for older callers that threaded Cloudflare auth through the module |
| `cloudflare_api_token_key_vault_id` | `string` | `null` | Key Vault resource ID used for the optional landing VM role assignment |
| `cloudflare_dns_allow_overwrite` | `bool` | `false` | Allow managed Cloudflare records to overwrite existing records |
| `create_root_evilginx_record` | `bool` | `true` | Create the apex/root A record that points to the Evilginx public IP |
| `create_wildcard_evilginx_record` | `bool` | `false` | Create the wildcard `*.<domain>` A record that points to the Evilginx public IP |
| `enable_evilginx_managed_identity` | `bool` | `false` | Enable a system-assigned managed identity on the Evilginx VM |
| `enable_gophish_managed_identity` | `bool` | `false` | Enable a system-assigned managed identity on the Gophish VM |
| `evilginx_additional_subdomains` | `list(string)` | `[]` | Additional Evilginx subdomains relative to `domain_name` |
| `evilginx_repo_ref` | `string` | `"30f20165749a5996d46a35b820b41c33a830327b"` | Git ref checked out when building Evilginx from source |
| `evilginx_vm_size` | `string` | `"Standard_B2s"` | Azure VM size for Evilginx |
| `go_linux_amd64_tarball_sha256` | `string` | `"904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0"` | SHA256 checksum for the Go Linux amd64 tarball downloaded in cloud-init |
| `go_version` | `string` | `"1.22.5"` | Go version installed before building Evilginx and Gophish |
| `gophish_repo_ref` | `string` | `"f88b204ee4f266bc7df6c6b954abf7b2e8afc22c"` | Git ref checked out when building Gophish from source |
| `gophish_vm_size` | `string` | `"Standard_B2s"` | Azure VM size for Gophish |
| `landing_additional_subdomains` | `list(string)` | `[]` | Additional landing subdomains when using the legacy landing hostname inputs |
| `landing_cloudflare_proxied` | `bool` | `true` | Proxy landing DNS records through Cloudflare |
| `landing_page_html` | `string` | built-in HTML document | Fallback `/index.html` content when `landing_site_files_base64` is empty |
| `landing_site_files_base64` | `map(string)` | `{}` | Map of relative file paths to base64-encoded content written under `/var/www/landing` |
| `landing_subdomain` | `string` | `"landing"` | Legacy primary landing subdomain |
| `landing_subdomains` | `list(string)` | `[]` | Full landing subdomain list; takes precedence when non-empty |
| `landing_vm_size` | `string` | `"Standard_B2s"` | Azure VM size for the landing server |
| `location` | `string` | `"East US"` | Azure region for all resources |
| `log_analytics_workspace_id` | `string` | `null` | Optional Log Analytics workspace resource ID for NSG diagnostics |
| `prefix` | `string` | `"redteam"` | Prefix token used in resource names |
| `resource_group_name` | `string` | `"rg-redteam-phishing"` | Azure resource group name |
| `restrict_outbound_traffic` | `bool` | `true` | Apply explicit outbound allow rules and a deny-all outbound baseline |
| `subnet_address_prefix` | `list(string)` | `["10.0.1.0/24"]` | Subnet CIDR list |
| `tags` | `map(string)` | `{}` | Additional tags merged with the module defaults |
| `vnet_address_space` | `list(string)` | `["10.0.0.0/16"]` | Virtual network CIDR list |

## Outputs

| Name | Description |
| --- | --- |
| `evilginx_fqdns` | All FQDNs routed to the Evilginx VM |
| `evilginx_public_ip` | Public IP address of the Evilginx VM |
| `evilginx_vm_principal_id` | System-assigned managed identity principal ID for the Evilginx VM, or `null` when disabled |
| `gophish_private_ip` | Private IP address of the Gophish VM |
| `gophish_public_ip` | Public IP address of the Gophish VM |
| `gophish_vm_principal_id` | System-assigned managed identity principal ID for the Gophish VM, or `null` when disabled |
| `landing_fqdn` | Primary FQDN of the landing web server |
| `landing_fqdns` | All landing FQDNs routed to the landing web server |
| `landing_public_ip` | Public IP address of the landing VM |
| `landing_url` | HTTPS URL of the landing page |
| `landing_vm_principal_id` | System-assigned managed identity principal ID for the landing VM |

## Testing

Run the module tests from the repository root:

```bash
terraform fmt -recursive
terraform test
```

[`tests/main.tftest.hcl`](tests/main.tftest.hcl) uses mocked providers and validates the module's plan shape, defaults, and DNS toggles.

## Authorized Use Only

Use this module only for authorized security assessments with written permission.

## License

MIT
