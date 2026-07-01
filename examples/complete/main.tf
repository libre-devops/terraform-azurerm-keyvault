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
