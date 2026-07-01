# Key vaults keyed by name, with secure defaults: RBAC authorization on (not legacy access policies),
# purge protection on, a 90 day soft-delete window, and a deny-by-default network ACL. tenant_id
# defaults to the caller's tenant. Access policies (legacy) and certificate contacts are optional. The
# resource group is passed by id and parsed.
locals {
  rg                  = provider::azurerm::parse_resource_id(var.resource_group_id)
  resource_group_name = local.rg.resource_group_name
  tenant_id           = coalesce(var.tenant_id, data.azurerm_client_config.current.tenant_id)
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  for_each = var.key_vaults

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  name      = each.key
  tenant_id = local.tenant_id
  sku_name  = each.value.sku_name

  rbac_authorization_enabled      = each.value.rbac_authorization_enabled
  purge_protection_enabled        = each.value.purge_protection_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  public_network_access_enabled   = each.value.public_network_access_enabled
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment

  dynamic "network_acls" {
    for_each = each.value.network_acls != null ? [each.value.network_acls] : []

    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  # Legacy access policies; only honoured when rbac_authorization_enabled is false.
  dynamic "access_policy" {
    for_each = each.value.access_policies

    content {
      tenant_id               = coalesce(access_policy.value.tenant_id, local.tenant_id)
      object_id               = access_policy.value.object_id
      application_id          = access_policy.value.application_id
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }
}

