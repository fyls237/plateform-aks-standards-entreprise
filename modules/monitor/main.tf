# ---------------------------------------------------------------------------
# Monitor Module — Main
# Diagnostic Settings, Alert Rules, Action Groups
# ---------------------------------------------------------------------------

locals {
  # Default AKS alert rules when user enables alerts but provides none
  default_alert_rules = var.enable_alerts && length(var.alert_rules) == 0 ? {
    "node-cpu-high" = {
      description = "Alert when node CPU utilization exceeds 85%"
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT15M"
      criteria = {
        metric_namespace = "Insights.Container/nodes"
        metric_name      = "cpuUsagePercentage"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 85
      }
    }
    "node-memory-high" = {
      description = "Alert when node memory utilization exceeds 85%"
      severity    = 2
      frequency   = "PT5M"
      window_size = "PT15M"
      criteria = {
        metric_namespace = "Insights.Container/nodes"
        metric_name      = "memoryWorkingSetPercentage"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 85
      }
    }
    "pod-restart-high" = {
      description = "Alert when pod restarts exceed threshold"
      severity    = 3
      frequency   = "PT5M"
      window_size = "PT15M"
      criteria = {
        metric_namespace = "Insights.Container/pods"
        metric_name      = "restartingContainerCount"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 5
      }
    }
  } : {}

  effective_alert_rules = length(var.alert_rules) > 0 ? var.alert_rules : local.default_alert_rules
}

# ---------------------------------------------------------------------------
# Diagnostic Settings for AKS
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count = var.enable_diagnostic_settings && var.aks_cluster_id != null ? 1 : 0

  name                       = "aks-diagnostics"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# ---------------------------------------------------------------------------
# Action Group
# ---------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "this" {
  count = var.enable_alerts ? 1 : 0

  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.action_group_name, "-", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers

    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Metric Alerts
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "this" {
  for_each = var.enable_alerts && var.aks_cluster_id != null ? local.effective_alert_rules : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = each.value.description
  severity            = each.value.severity
  frequency           = each.value.frequency
  window_size         = each.value.window_size

  criteria {
    metric_namespace = each.value.criteria.metric_namespace
    metric_name      = each.value.criteria.metric_name
    aggregation      = each.value.criteria.aggregation
    operator         = each.value.criteria.operator
    threshold        = each.value.criteria.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = var.tags
}
