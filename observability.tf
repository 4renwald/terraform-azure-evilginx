# =============================================================================
# Observability - Diagnostics
# =============================================================================

resource "azurerm_monitor_diagnostic_setting" "nsg_evilginx" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "diag-nsg-evilginx-${var.prefix}"
  target_resource_id         = azurerm_network_security_group.evilginx.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_gophish" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "diag-nsg-gophish-${var.prefix}"
  target_resource_id         = azurerm_network_security_group.gophish.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_landing" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "diag-nsg-landing-${var.prefix}"
  target_resource_id         = azurerm_network_security_group.landing.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
