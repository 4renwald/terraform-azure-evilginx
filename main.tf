# =============================================================================
# Terraform Module: Azure VM Stack (Evilginx + Gophish + Landing)
# =============================================================================
# This module deploys three Ubuntu VMs (evilginx + gophish + landing web
# server), with networking, Cloudflare DNS, and automated provisioning via
# cloud-init.
#
# File layout:
#   main.tf      - Resource group (this file)
#   locals.tf    - Local values and tags
#   network.tf   - VNet, subnet, public IPs, NICs
#   security.tf  - Network security groups
#   observability.tf - Optional diagnostic settings
#   compute.tf   - Linux virtual machines
#   dns.tf       - Cloudflare DNS A records
#   variables.tf - Input variables
#   outputs.tf   - Output values
#   providers.tf - Provider configuration
#   versions.tf  - Terraform and provider version constraints
#   backend.tf   - Remote state backend (Azure Storage)
# =============================================================================

# =============================================================================
# Resource Group
# =============================================================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}
