# --------------------------------------------------------------------------
# Terraform Test: Basic module validation
# --------------------------------------------------------------------------
# Validates the module can be initialized and planned with valid inputs.
# Run with: terraform test
# --------------------------------------------------------------------------

mock_provider "azurerm" {}
mock_provider "cloudflare" {}

variables {
  domain_name                             = "test-phishing.example.com"
  ssh_public_key                          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3c7bIDerIXJSNcyywD1/WrzHO3EIfvWywpnzcn5cLatFVJ++pQxro7U0sS/p7qReTqAUHs54NXUvoe6joWULkpZb/rXeQeuS/WDZsSy2b3dnjFNOIOr3S7S4+HOlHXFJooCBQWk+ne8YA3aDrEWgv3nNdzIRsJKFpUdf34+s2FIdDXiyR237TLBhk+HYVl3T1WRUFE6i+upmeJSAFbYpfNJ2zqeRRtY6E0FmUTYJTitmnOuzr83Dkds6BSICFAglb4kj7mbTYCwCx9vxbPCGjGmXzXyZVz/4VbQO2jKoJukA5W3G3+LRVg71xtWmuEAKsHcWoI8OznRrHUXjv82KD arenwald@windows"
  allowed_ssh_cidr                        = "203.0.113.10/32"
  landing_subdomain                       = "landing"
  landing_additional_subdomains           = ["promo"]
  certbot_email                           = "ops@example.com"
  cloudflare_zone_id                      = "zoneid123"
  cloudflare_api_token                    = "cf-token-placeholder"
  cloudflare_api_token_key_vault_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.KeyVault/vaults/test-kv"
  landing_cloudflare_api_token_secret_uri = "https://test-kv.vault.azure.net/secrets/cloudflare-token/11111111111111111111111111111111"
  ubuntu_image_version                    = "22.04.202501150"
}

run "validate_plan" {
  command = plan

  assert {
    condition     = azurerm_resource_group.main.name == "rg-redteam-phishing"
    error_message = "Resource group name should use the default value."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.evilginx.size == "Standard_B2s"
    error_message = "Evilginx VM should use the default size."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.gophish.size == "Standard_B2s"
    error_message = "Gophish VM should use the default size."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.landing.size == "Standard_B2s"
    error_message = "Landing VM should use the default size."
  }

  assert {
    condition     = cloudflare_record.root.name == "test-phishing.example.com"
    error_message = "Root Cloudflare record should target the module domain."
  }

  assert {
    condition     = length(cloudflare_record.wildcard) == 0
    error_message = "Wildcard Cloudflare record should not be created by default."
  }

  assert {
    condition     = cloudflare_record.landing_subdomains["landing.test-phishing.example.com"].name == "landing.test-phishing.example.com"
    error_message = "Landing Cloudflare record should exist for landing_subdomain."
  }

  assert {
    condition     = cloudflare_record.landing_subdomains["promo.test-phishing.example.com"].name == "promo.test-phishing.example.com"
    error_message = "Landing Cloudflare record should exist for landing_additional_subdomains."
  }
}
