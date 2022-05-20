resource "azurerm_key_vault" "keyvault" {

  name                            = var.kv_name
  location                        = var.location
  resource_group_name             = var.rg_name
  tenant_id                       = var.tenant_id
  sku_name                        = lower(try(var.sku_name, "standard"))
  tags                            = var.tags
  enabled_for_deployment          = try(var.enabled_for_deployment, false)
  enabled_for_disk_encryption     = try(var.enabled_for_disk_encryption, false)
  enabled_for_template_deployment = try(var.enabled_for_template_deployment, false)
  purge_protection_enabled        = try(var.purge_protection_enabled, false)
  soft_delete_retention_days      = try(var.soft_delete_retention_days, 7)
  enable_rbac_authorization       = try(var.enable_rbac_authorization, false)
  timeouts {
    delete = "60m"

  }

  dynamic "network_acls" {
    for_each = lookup(var.settings, "network", null) == null ? [] : [1]

    content {
      bypass         = var.settings.network.bypass
      default_action = try(var.settings.network.default_action, "Deny")
      ip_rules       = try(var.settings.network.ip_rules, null)
      virtual_network_subnet_ids = try(var.settings.network.subnets, null)
    }
  }

  dynamic "contact" {
    for_each = lookup(var.settings, "contacts", {})

    content {
      email = contact.value.email
      name  = try(contact.value.name, null)
      phone = try(contact.value.phone, null)
    }
  }

  lifecycle {
    ignore_changes = [
      resource_group_name, location
    ]
  }
}
