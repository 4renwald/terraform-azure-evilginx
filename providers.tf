# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
# This provider block is defined here for direct (root module) usage.
# When consuming this repo as a child module via `module "redteam" {}`,
# the calling root module should define its own provider block instead.
#
# AzureRM 4.x requires subscription_id. Set it via the ARM_SUBSCRIPTION_ID
# environment variable, or uncomment and hardcode below:
#   subscription_id = "<YOUR_SUBSCRIPTION_ID>"
# Cloudflare resources require authentication via provider config or the
# CLOUDFLARE_API_TOKEN environment variable in the root module.
# -----------------------------------------------------------------------------

# provider "azurerm" {
#   features {}
# }
