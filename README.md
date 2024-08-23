```hcl
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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.client_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_client_config.current_client](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_full_certificate_permissions"></a> [full\_certificate\_permissions](#input\_full\_certificate\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Create",<br>  "Delete",<br>  "DeleteIssuers",<br>  "Get",<br>  "GetIssuers",<br>  "Import",<br>  "List",<br>  "ListIssuers",<br>  "ManageContacts",<br>  "ManageIssuers",<br>  "Purge",<br>  "Recover",<br>  "Restore",<br>  "SetIssuers",<br>  "Update"<br>]</pre> | no |
| <a name="input_full_key_permissions"></a> [full\_key\_permissions](#input\_full\_key\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Create",<br>  "Decrypt",<br>  "Delete",<br>  "Encrypt",<br>  "Get",<br>  "Import",<br>  "List",<br>  "Purge",<br>  "Recover",<br>  "Restore",<br>  "Sign",<br>  "UnwrapKey",<br>  "Update",<br>  "Verify",<br>  "WrapKey"<br>]</pre> | no |
| <a name="input_full_secret_permissions"></a> [full\_secret\_permissions](#input\_full\_secret\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Delete",<br>  "Get",<br>  "List",<br>  "Purge",<br>  "Recover",<br>  "Restore",<br>  "Set"<br>]</pre> | no |
| <a name="input_full_storage_permissions"></a> [full\_storage\_permissions](#input\_full\_storage\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Delete",<br>  "DeleteSAS",<br>  "Get",<br>  "GetSAS",<br>  "List",<br>  "ListSAS",<br>  "Purge",<br>  "Recover",<br>  "RegenerateKey",<br>  "Restore",<br>  "Set",<br>  "SetSAS",<br>  "Update"<br>]</pre> | no |
| <a name="input_give_current_client_full_access"></a> [give\_current\_client\_full\_access](#input\_give\_current\_client\_full\_access) | If you use your current client as the tenant id, do you wish to give it full access to the keyvault? this aids automation, and is thus enable by default for this module.  Disable for better security by setting to false | `bool` | `false` | no |
| <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults) | A list of key vaults to create | <pre>list(object({<br>    name                            = string<br>    location                        = string<br>    rg_name                         = string<br>    sku_name                        = optional(string, "standard")<br>    tenant_id                       = optional(string)<br>    enabled_for_deployment          = optional(bool, true)<br>    enabled_for_disk_encryption     = optional(bool, true)<br>    enabled_for_template_deployment = optional(bool, true)<br>    soft_delete_retention_days      = optional(number)<br>    public_network_access_enabled   = optional(bool)<br>    enable_rbac_authorization       = optional(bool, true)<br>    purge_protection_enabled        = optional(bool, false) # Easier for automation<br>    access_policy = optional(list(object({<br>      tenant_id           = string<br>      object_id           = string<br>      key_permissions     = list(string)<br>      secret_permissions  = list(string)<br>      storage_permissions = list(string)<br>    })))<br>    network_acls = optional(object({<br>      bypass                     = string<br>      default_action             = string<br>      ip_rules                   = list(string)<br>      virtual_network_subnet_ids = list(string)<br>    }))<br>    contact = optional(list(object({<br>      email = string<br>      name  = optional(string)<br>      phone = optional(string)<br>    })))<br>    tags = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_use_current_client"></a> [use\_current\_client](#input\_use\_current\_client) | If you wish to use the current client config or not | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_access_policy_certificate_permissions"></a> [client\_access\_policy\_certificate\_permissions](#output\_client\_access\_policy\_certificate\_permissions) | The key permissions of the client access policy. |
| <a name="output_client_access_policy_id"></a> [client\_access\_policy\_id](#output\_client\_access\_policy\_id) | The ID of the client access policy. |
| <a name="output_client_access_policy_key_permissions"></a> [client\_access\_policy\_key\_permissions](#output\_client\_access\_policy\_key\_permissions) | The key permissions of the client access policy. |
| <a name="output_client_access_policy_secret_permissions"></a> [client\_access\_policy\_secret\_permissions](#output\_client\_access\_policy\_secret\_permissions) | The key permissions of the client access policy. |
| <a name="output_key_vault_ids"></a> [key\_vault\_ids](#output\_key\_vault\_ids) | The IDs of the created Key Vaults. |
| <a name="output_key_vault_locations"></a> [key\_vault\_locations](#output\_key\_vault\_locations) | The locations of the created Key Vaults. |
| <a name="output_key_vault_names"></a> [key\_vault\_names](#output\_key\_vault\_names) | The names of the created Key Vaults. |
| <a name="output_key_vault_uris"></a> [key\_vault\_uris](#output\_key\_vault\_uris) | The uris of the created Key Vaults. |
