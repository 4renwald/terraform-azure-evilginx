# =============================================================================
# Compute — Linux Virtual Machines
# =============================================================================

# -----------------------------------------------------------------------------
# Evilginx VM
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "evilginx" {
  depends_on = [
    azurerm_network_interface_security_group_association.evilginx
  ]

  name                            = "vm-evilginx-${var.prefix}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = var.evilginx_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data = base64encode(templatefile("${path.module}/templates/evilginx-cloud-init.yaml", {
    evilginx_repo_ref             = var.evilginx_repo_ref
    go_version                    = var.go_version
    go_linux_amd64_tarball_sha256 = var.go_linux_amd64_tarball_sha256
  }))
  tags = local.common_tags

  network_interface_ids = [
    azurerm_network_interface.evilginx.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  dynamic "identity" {
    for_each = var.enable_evilginx_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  os_disk {
    name                 = "osdisk-evilginx-${var.prefix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = var.ubuntu_image_version
  }
}

# -----------------------------------------------------------------------------
# Gophish VM
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "gophish" {
  depends_on = [
    azurerm_network_interface_security_group_association.gophish
  ]

  name                            = "vm-gophish-${var.prefix}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = var.gophish_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data = base64encode(templatefile("${path.module}/templates/gophish-cloud-init.yaml", {
    gophish_repo_ref              = var.gophish_repo_ref
    go_version                    = var.go_version
    go_linux_amd64_tarball_sha256 = var.go_linux_amd64_tarball_sha256
  }))
  tags = local.common_tags

  network_interface_ids = [
    azurerm_network_interface.gophish.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  dynamic "identity" {
    for_each = var.enable_gophish_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  os_disk {
    name                 = "osdisk-gophish-${var.prefix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = var.ubuntu_image_version
  }
}

# -----------------------------------------------------------------------------
# Landing Web VM
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "landing" {
  depends_on = [
    azurerm_network_interface_security_group_association.landing
  ]

  name                            = "vm-landing-${var.prefix}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = var.landing_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data = base64encode(templatefile("${path.module}/templates/landing-cloud-init.yaml", {
    landing_primary_fqdn                    = local.landing_primary_fqdn
    landing_server_names                    = local.landing_server_names
    landing_certbot_domain_args             = local.landing_certbot_domain_args
    certbot_email                           = var.certbot_email
    landing_cloudflare_api_token_secret_uri = var.landing_cloudflare_api_token_secret_uri
    landing_site_files                      = local.landing_site_files
  }))
  tags = local.common_tags

  network_interface_ids = [
    azurerm_network_interface.landing.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-landing-${var.prefix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = var.ubuntu_image_version
  }
}

resource "azurerm_role_assignment" "landing_key_vault_secrets_user" {
  count = (
    var.assign_key_vault_role_to_landing_vm && var.cloudflare_api_token_key_vault_id != null
  ) ? 1 : 0

  scope                = var.cloudflare_api_token_key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.landing.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
