data "azurerm_client_config" "current_client" {
  count = var.use_current_client == true ? 1 : 0
}

resource "azurerm_key_vault_access_policy" "client_access" {
  count        = var.use_current_client == true && var.give_current_client_full_access == true ? 1 : 0
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current_client.tenant_id
  object_id    = data.azurerm_client_config.current_client.object_id

  key_permissions         = tolist(var.full_key_permissions)
  secret_permissions      = tolist(var.full_secret_permissions)
  certificate_permissions = tolist(var.full_certificate_permissions)
  storage_permissions     = tolist(var.full_storage_permissions)
}

resource "azurerm_key_vault" "keyvault" {

  name                            = var.kv_name
  location                        = var.location
  resource_group_name             = var.rg_name
  tenant_id                       = var.use_current_client == true ? element(data.azurerm_client_config.current_client.*.tenant_id, 0) : try(var.tenant_id, null)
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
      bypass                     = var.settings.network.bypass
      default_action             = try(var.settings.network.default_action, "Deny")
      ip_rules                   = try(var.settings.network.ip_rules, null)
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
