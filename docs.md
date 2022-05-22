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
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Whether key vault access policy or Azure rbac is used, default is false as the key vault access policy is the default behavior for this module | `bool` | `false` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Enable this keyvault for template deployments access | `bool` | `true` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | If this keyvault is enabled for disk encryption | `bool` | `true` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | If this keyvault is enabled for ARM template deployments | `bool` | `true` | no |
| <a name="input_full_certificate_permissions"></a> [full\_certificate\_permissions](#input\_full\_certificate\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Create",<br>  "Delete",<br>  "DeleteIssuers",<br>  "Get",<br>  "GetIssuers",<br>  "Import",<br>  "List",<br>  "ListIssuers",<br>  "ManageContacts",<br>  "ManageIssuers",<br>  "Purge",<br>  "Recover",<br>  "Restore",<br>  "SetIssuers",<br>  "Update"<br>]</pre> | no |
| <a name="input_full_key_permissions"></a> [full\_key\_permissions](#input\_full\_key\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Create",<br>  "Decrypt",<br>  "Delete",<br>  "Encrypt",<br>  "Get",<br>  "Import",<br>  "List",<br>  "Purge",<br>  "Recover",<br>  "Restore",<br>  "Sign",<br>  "UnwrapKey",<br>  "Update",<br>  "Verify",<br>  "WrapKey"<br>]</pre> | no |
| <a name="input_full_secret_permissions"></a> [full\_secret\_permissions](#input\_full\_secret\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Delete",<br>  "Get",<br>  "List",<br>  "Purge",<br>  "Recover",<br>  "Restore",<br>  "Set"<br>]</pre> | no |
| <a name="input_full_storage_permissions"></a> [full\_storage\_permissions](#input\_full\_storage\_permissions) | All the available permissions for key access | `list(string)` | <pre>[<br>  "Backup",<br>  "Delete",<br>  "DeleteSAS",<br>  "Get",<br>  "GetSAS",<br>  "List",<br>  "ListSAS",<br>  "Purge",<br>  "Recover",<br>  "RegenerateKey",<br>  "Restore",<br>  "Set",<br>  "SetSAS",<br>  "Update"<br>]</pre> | no |
| <a name="input_give_current_client_full_access"></a> [give\_current\_client\_full\_access](#input\_give\_current\_client\_full\_access) | If you use your current client as the tenant id, do you wish to give it full access to the keyvault? this aids automation, and is thus enable by default for this module.  Disable for better security by setting to false | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_kv_name"></a> [kv\_name](#input\_kv\_name) | The name of the keyvault | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | If purge protection is enabled, for automation, it is recomended to be disabled so you can delete it, but for security, it should be enabled.  defaults to false to | `bool` | `false` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | A map used for the settings blocks | `any` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The sku of your keyvault, defaults to standard | `string` | `"Standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days for soft delete, defaults to 7 the minimum | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | If you are not using current client\_config, set tenant id here | `string` | `null` | no |
| <a name="input_use_current_client"></a> [use\_current\_client](#input\_use\_current\_client) | If you wish to use the current client config or not | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_certificate_permissions"></a> [full\_certificate\_permissions](#output\_full\_certificate\_permissions) | Full permissions to the certificate permission set, used as a variable in the module |
| <a name="output_full_key_permissions"></a> [full\_key\_permissions](#output\_full\_key\_permissions) | Full permissions to the key permission set, used as a variable in the module |
| <a name="output_full_secret_permissions"></a> [full\_secret\_permissions](#output\_full\_secret\_permissions) | Full permissions to the secret permission set, used as a variable in the module |
| <a name="output_full_storage_permissions"></a> [full\_storage\_permissions](#output\_full\_storage\_permissions) | Full permissions to the storage permission set, used as a variable in the module |
| <a name="output_kv_id"></a> [kv\_id](#output\_kv\_id) | The id of the keyvault |
| <a name="output_kv_name"></a> [kv\_name](#output\_kv\_name) | The name of the keyvault |
| <a name="output_kv_tenant_id"></a> [kv\_tenant\_id](#output\_kv\_tenant\_id) | The keyvault tenant id |
