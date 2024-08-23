data "azurerm_client_config" "current_client" {
  count = var.use_current_client == true ? 1 : 0
}

resource "azurerm_key_vault_access_policy" "client_access" {
  count        = var.use_current_client == true && var.give_current_client_full_access == true ? 1 : 0
  key_vault_id = azurerm_key_vault.keyvault[0].id # Adjust index based on which key vault the policy should apply to
  tenant_id    = element(data.azurerm_client_config.current_client.*.tenant_id, 0)
  object_id    = element(data.azurerm_client_config.current_client.*.object_id, 0)

  key_permissions         = tolist(var.full_key_permissions)
  secret_permissions      = tolist(var.full_secret_permissions)
  certificate_permissions = tolist(var.full_certificate_permissions)
  storage_permissions     = tolist(var.full_storage_permissions)
}

resource "azurerm_key_vault" "keyvault" {
  for_each = { for vault, key_vault in var.key_vaults : vault => key_vault }

  name                            = each.value.name
  location                        = each.value.location
  resource_group_name             = each.value.rg_name
  sku_name                        = lower(each.value.sku_name)
  tenant_id                       = var.use_current_client == true ? data.azurerm_client_config.current_client[0].tenant_id : each.value.tenant_id
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  enable_rbac_authorization       = each.value.enable_rbac_authorization
  purge_protection_enabled        = each.value.purge_protection_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  public_network_access_enabled   = each.value.public_network_access_enabled

  dynamic "access_policy" {
    for_each = each.value.access_policy != null ? each.value.access_policy : []
    content {
      tenant_id = access_policy.value.tenant_id
      object_id = access_policy.value.object_id

      key_permissions     = access_policy.value.key_permissions
      secret_permissions  = access_policy.value.secret_permissions
      storage_permissions = access_policy.value.storage_permissions
    }
  }

  dynamic "network_acls" {
    for_each = each.value.network_acls != null ? [each.value.network_acls] : []
    content {
      bypass                     = network_acls.value.bypass
      default_action             = title(network_acls.value.default_action)
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  #   dynamic "contact" {
  #     for_each = each.value.contact != null ? each.value.contact : []
  #     content {
  #       email = contact.value.email
  #       name  = contact.value.name
  #       phone = contact.value.phone
  #     }
  #   }

  tags = each.value.tags
}
