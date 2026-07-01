<!--
  Header for the complete example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
  The example's main.tf is embedded into the README automatically (see .terraform-docs.yml).
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="200">
    </picture>
  </a>
</div>

# Complete example

Exercises the fuller surface of this module. The environment comes from the Terraform workspace
(`terraform.workspace`), not a variable. Run it with `just e2e complete`, which applies the stack
then always destroys it.

[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)

<!-- BEGIN_TF_DOCS -->
## Example configuration

```hcl
locals {
  location    = lookup(var.regions, var.loc, "uksouth")
  rg_name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  law_name    = "log-${var.short}-${var.loc}-${terraform.workspace}-002"
  kv_rbac     = "kv-${var.short}-${var.loc}-${terraform.workspace}-002"
  kv_policies = "kv-${var.short}-${var.loc}-${terraform.workspace}-003"
}

data "azurerm_client_config" "current" {}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-keyvault" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Destination for the vault diagnostics.
module "log_analytics" {
  source  = "libre-devops/log-analytics-workspace/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  log_analytics_workspaces = { (local.law_name) = {} }
}

# Complete call: two vaults. One uses RBAC with a network allow-list and disk-encryption enablement;
# the other uses legacy access policies (granting the caller secret access). purge_protection is off on
# both only so the example is disposable; leave it at the default (true) for real vaults.
module "keyvault" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  key_vaults = {
    (local.kv_rbac) = {
      purge_protection_enabled    = false
      enabled_for_disk_encryption = true
      network_acls = {
        default_action = "Deny"
        bypass         = "AzureServices"
        ip_rules       = ["203.0.113.0/24"]
      }
    }
    (local.kv_policies) = {
      rbac_authorization_enabled = false
      purge_protection_enabled   = false
      access_policies = [
        {
          object_id          = data.azurerm_client_config.current.object_id
          key_permissions    = ["Get", "List"]
          secret_permissions = ["Get", "List", "Set"]
        }
      ]
    }
  }
}

# Ship both vaults' logs and metrics to the workspace via the diagnostic-settings module.
module "diagnostics" {
  source  = "libre-devops/diagnostic-settings/azurerm"
  version = "~> 4.0"

  log_analytics_workspace_id = module.log_analytics.workspace_ids[local.law_name]

  diagnostic_settings = {
    "kv-rbac"     = { target_resource_id = module.keyvault.ids[local.kv_rbac] }
    "kv-policies" = { target_resource_id = module.keyvault.ids[local.kv_policies] }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics) | libre-devops/diagnostic-settings/azurerm | ~> 4.0 |
| <a name="module_keyvault"></a> [keyvault](#module\_keyvault) | ../../ | n/a |
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | libre-devops/log-analytics-workspace/azurerm | ~> 4.0 |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | ~> 4.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | libre-devops/tags/azurerm | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployed_branch"></a> [deployed\_branch](#input\_deployed\_branch) | Git branch the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_branch. | `string` | `""` | no |
| <a name="input_deployed_repo"></a> [deployed\_repo](#input\_deployed\_repo) | Repository URL the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_repo. | `string` | `""` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | Outfix: short Azure region code used in resource names (for example uks). | `string` | `"uks"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Map of short region codes to Azure region slugs. | `map(string)` | <pre>{<br/>  "eus": "eastus",<br/>  "euw": "westeurope",<br/>  "uks": "uksouth",<br/>  "ukw": "ukwest"<br/>}</pre> | no |
| <a name="input_short"></a> [short](#input\_short) | Infix: short product code used in resource names. | `string` | `"ldo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | The diagnostic setting ids shipping vault logs to the workspace. |
| <a name="output_key_vault_ids"></a> [key\_vault\_ids](#output\_key\_vault\_ids) | Map of key vault name to resource id. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources. |
| <a name="output_vault_uris"></a> [vault\_uris](#output\_vault\_uris) | Map of key vault name to data-plane URI. |
<!-- END_TF_DOCS -->
