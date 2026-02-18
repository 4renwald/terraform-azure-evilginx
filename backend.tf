# -----------------------------------------------------------------------------
# Azure Storage Backend Configuration
# -----------------------------------------------------------------------------
# Uncomment and configure the backend block below to use Azure Blob Storage
# for remote state management with locking. You must pre-create the storage
# account and container before running terraform init.
#
# Alternatively, set these values via CLI flags:
#   terraform init \
#     -backend-config="resource_group_name=rg-terraform-state" \
#     -backend-config="storage_account_name=stterraformstate" \
#     -backend-config="container_name=tfstate" \
#     -backend-config="key=redteam-phishing.tfstate"
# -----------------------------------------------------------------------------

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "<BACKEND_RG>"          # e.g. "rg-terraform-state"
#     storage_account_name = "<BACKEND_SA>"          # e.g. "stterraformstate"
#     container_name       = "tfstate"
#     key                  = "redteam-phishing.tfstate"
#   }
# }
