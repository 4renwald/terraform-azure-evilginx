# =============================================================================
# Network Security Groups
# =============================================================================
# NOTE: Azure NSGs allow all outbound traffic by default.
# Set `restrict_outbound_traffic = true` to enforce an explicit egress policy
# with allow rules for DNS/HTTP/HTTPS and a deny-all outbound baseline.
# =============================================================================

# -----------------------------------------------------------------------------
# Evilginx NSG
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "evilginx" {
  name                = "nsg-evilginx-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  # SSH — restricted to operator CIDR
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  # HTTP
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTPS
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # DNS TCP
  security_rule {
    name                       = "Allow-DNS-TCP"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # DNS UDP
  security_rule {
    name                       = "Allow-DNS-UDP"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow private east-west traffic from Gophish.
  security_rule {
    name                       = "Allow-Gophish-Private-In"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_network_interface.gophish.private_ip_address
    destination_address_prefix = "*"
  }

  # Allow private east-west traffic to Gophish.
  security_rule {
    name                       = "Allow-Gophish-Private-Out"
    priority                   = 3400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_network_interface.gophish.private_ip_address
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-DNS-UDP-Out"
      priority                   = 3500
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-DNS-TCP-Out"
      priority                   = 3501
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-HTTP-Out"
      priority                   = 3510
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-HTTPS-Out"
      priority                   = 3511
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Deny-All-Out"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

# -----------------------------------------------------------------------------
# Gophish NSG
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "gophish" {
  name                = "nsg-gophish-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  # SSH — restricted to operator CIDR
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  # Gophish admin — restricted to operator CIDR
  security_rule {
    name                       = "Allow-Gophish-Admin"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3333"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  # HTTP — public content (if used)
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow private east-west traffic from Evilginx.
  security_rule {
    name                       = "Allow-Evilginx-Private-In"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_network_interface.evilginx.private_ip_address
    destination_address_prefix = "*"
  }

  # Allow private east-west traffic to Evilginx.
  security_rule {
    name                       = "Allow-Evilginx-Private-Out"
    priority                   = 3400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_network_interface.evilginx.private_ip_address
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-DNS-UDP-Out"
      priority                   = 3500
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-DNS-TCP-Out"
      priority                   = 3501
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-HTTP-Out"
      priority                   = 3510
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-HTTPS-Out"
      priority                   = 3511
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-SMTP-25-Out"
      priority                   = 3520
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "25"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-SMTPS-465-Out"
      priority                   = 3521
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "465"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-Submission-587-Out"
      priority                   = 3522
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "587"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-SMTP-2525-Out"
      priority                   = 3523
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "2525"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Deny-All-Out"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

# -----------------------------------------------------------------------------
# Landing Web NSG
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "landing" {
  name                = "nsg-landing-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  # SSH — restricted to operator CIDR
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  # HTTP
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTPS
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-DNS-UDP-Out"
      priority                   = 3500
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-DNS-TCP-Out"
      priority                   = 3501
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-HTTP-Out"
      priority                   = 3510
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Allow-HTTPS-Out"
      priority                   = 3511
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  dynamic "security_rule" {
    for_each = var.restrict_outbound_traffic ? [1] : []
    content {
      name                       = "Deny-All-Out"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
