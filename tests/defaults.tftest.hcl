# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  tenant_id         = "00000000-0000-0000-0000-000000000000"

  key_vaults = {
    "kv-ldo-uks-tst-001" = {}
  }
}

run "creates_vault_with_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_key_vault.this["kv-ldo-uks-tst-001"].rbac_authorization_enabled == true && azurerm_key_vault.this["kv-ldo-uks-tst-001"].purge_protection_enabled == true
    error_message = "Vaults should default to RBAC authorization and purge protection enabled."
  }

  assert {
    condition     = one(azurerm_key_vault.this["kv-ldo-uks-tst-001"].network_acls).default_action == "Deny"
    error_message = "The default network ACL should deny by default."
  }

  assert {
    condition     = output.resource_group_name == "rg-ldo-uks-tst-001"
    error_message = "resource_group_name should be parsed from resource_group_id."
  }
}

run "supports_legacy_access_policies" {
  command = plan

  variables {
    key_vaults = {
      "kv-ldo-uks-tst-002" = {
        rbac_authorization_enabled = false
        purge_protection_enabled   = false
        access_policies = [
          {
            object_id          = "11111111-1111-1111-1111-111111111111"
            secret_permissions = ["Get", "List"]
          }
        ]
      }
    }
  }

  assert {
    condition     = length(azurerm_key_vault.this["kv-ldo-uks-tst-002"].access_policy) == 1
    error_message = "Access policies should be created from the list when RBAC is disabled."
  }
}

run "rejects_invalid_sku" {
  command = plan

  variables {
    key_vaults = { "kv-bad" = { sku_name = "ultra" } }
  }

  expect_failures = [var.key_vaults]
}

run "rejects_retention_out_of_range" {
  command = plan

  variables {
    key_vaults = { "kv-bad" = { soft_delete_retention_days = 400 } }
  }

  expect_failures = [var.key_vaults]
}
