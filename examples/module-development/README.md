```hcl
module "rg" {
  source = "libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

module "shared_vars" {
  source = "libre-devops/shared-vars/azurerm"
}

locals {
  lookup_cidr = {
    for landing_zone, envs in module.shared_vars.cidrs : landing_zone => {
      for env, cidr in envs : env => cidr
    }
  }
}

module "subnet_calculator" {
  source = "libre-devops/subnet-calculator/null"

  base_cidr    = local.lookup_cidr[var.short][var.env][0]
  subnet_sizes = [26]
}

module "network" {
  source = "libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = [module.subnet_calculator.base_cidr]

  subnets = {
    for i, name in module.subnet_calculator.subnet_names :
    name => {
      address_prefixes  = toset([module.subnet_calculator.subnet_ranges[i]])
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
  }
}

data "http" "user_ip" {
  url = "https://checkip.amazonaws.com"
}

module "role_assignments" {
  source = "github.com/libre-devops/terraform-azurerm-role-assignment"

  role_assignments = [
    {
      principal_ids = [data.azurerm_client_config.current.object_id]
      role_names    = ["Key Vault Administrator"]
      scope         = module.rg.rg_id
      set_condition = true
    },
  ]
}
module "law" {
  source = "registry.terraform.io/libre-devops/log-analytics-workspace/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  create_new_workspace       = true
  law_name                   = "law-${var.short}-${var.loc}-${var.env}-01"
  law_sku                    = "PerGB2018"
  retention_in_days          = "30"
  daily_quota_gb             = "0.5"
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}

module "key_vault" {
  source = "../../"

  key_vaults = [
    {
      name     = "kv-${var.short}-${var.loc}-${var.env}-tst-01"
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      create_diagnostic_settings                      = true
      diagnostic_settings_enable_all_logs_and_metrics = true
      diagnostic_settings = {
        law_id = module.law.law_id
      }

      enabled_for_deployment          = true
      enabled_for_disk_encryption     = true
      enabled_for_template_deployment = true
      enable_rbac_authorization       = true
      purge_protection_enabled        = false
      public_network_access_enabled   = true
      network_acls = {
        default_action             = "Deny"
        bypass                     = "AzureServices"
        ip_rules                   = [chomp(data.http.user_ip.response_body)]
        virtual_network_subnet_ids = [module.network.subnets_ids["subnet1"]]
      }
    },
    {
      name     = "kv-${var.short}-${var.loc}-${var.env}-tst-02"
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      create_diagnostic_settings                      = true
      diagnostic_settings_enable_all_logs_and_metrics = false
      diagnostic_settings = {
        law_id = module.law.law_id
        enabled_log = [
          {
            category = "AuditEvent"
          }
        ]
      }

      enabled_for_deployment          = true
      enabled_for_disk_encryption     = true
      enabled_for_template_deployment = true
      enable_rbac_authorization       = true
      purge_protection_enabled        = false
      public_network_access_enabled   = true
      network_acls = {
        default_action             = "Deny"
        bypass                     = "AzureServices"
        ip_rules                   = [chomp(data.http.user_ip.response_body)]
        virtual_network_subnet_ids = [module.network.subnets_ids["subnet1"]]
      }
    }
  ]
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.1.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ../../ | n/a |
| <a name="module_law"></a> [law](#module\_law) | registry.terraform.io/libre-devops/log-analytics-workspace/azurerm | n/a |
| <a name="module_network"></a> [network](#module\_network) | libre-devops/network/azurerm | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | n/a |
| <a name="module_role_assignments"></a> [role\_assignments](#module\_role\_assignments) | github.com/libre-devops/terraform-azurerm-role-assignment | n/a |
| <a name="module_shared_vars"></a> [shared\_vars](#module\_shared\_vars) | libre-devops/shared-vars/azurerm | n/a |
| <a name="module_subnet_calculator"></a> [subnet\_calculator](#module\_subnet\_calculator) | libre-devops/subnet-calculator/null | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.entropy](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.mgmt_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_user_assigned_identity.mgmt_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [http_http.user_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | This is passed as an environment variable, it is for the shorthand environment tag for resource.  For example, production = prod | `string` | `"prd"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The shorthand name of the Azure location, for example, for UK South, use uks.  For UK West, use ukw. Normally passed as TF\_VAR in pipeline | `string` | `"uks"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of this resource | `string` | `"tst"` | no |
| <a name="input_short"></a> [short](#input\_short) | This is passed as an environment variable, it is for a shorthand name for the environment, for example hello-world = hw | `string` | `"lbd"` | no |

## Outputs

No outputs.
