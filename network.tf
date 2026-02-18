# =============================================================================
# Networking — VNet, Subnet, Public IPs, NICs, NSG Associations
# =============================================================================

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-${var.prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefix
}

# -----------------------------------------------------------------------------
# Public IPs
# -----------------------------------------------------------------------------

resource "azurerm_public_ip" "evilginx" {
  name                = "pip-evilginx-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_public_ip" "gophish" {
  name                = "pip-gophish-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_public_ip" "landing" {
  name                = "pip-landing-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Network Interfaces
# -----------------------------------------------------------------------------

resource "azurerm_network_interface" "evilginx" {
  name                = "nic-evilginx-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.evilginx.id
  }
}

resource "azurerm_network_interface" "gophish" {
  name                = "nic-gophish-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gophish.id
  }
}

resource "azurerm_network_interface" "landing" {
  name                = "nic-landing-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.landing.id
  }
}

# -----------------------------------------------------------------------------
# NSG <-> NIC Associations
# -----------------------------------------------------------------------------

resource "azurerm_network_interface_security_group_association" "evilginx" {
  network_interface_id      = azurerm_network_interface.evilginx.id
  network_security_group_id = azurerm_network_security_group.evilginx.id
}

resource "azurerm_network_interface_security_group_association" "gophish" {
  network_interface_id      = azurerm_network_interface.gophish.id
  network_security_group_id = azurerm_network_security_group.gophish.id
}

resource "azurerm_network_interface_security_group_association" "landing" {
  network_interface_id      = azurerm_network_interface.landing.id
  network_security_group_id = azurerm_network_security_group.landing.id
}
