output "ids" {
  description = "Map of key vault name to its resource id."
  value       = { for k, v in azurerm_key_vault.this : k => v.id }
}

output "ids_zipmap" {
  description = "Map of key vault name to a { name, id } object, for passing where both are needed together."
  value       = { for k, v in azurerm_key_vault.this : k => { name = v.name, id = v.id } }
}

output "names" {
  description = "The key vault names."
  value       = keys(azurerm_key_vault.this)
}

output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.resource_group_name
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "tags" {
  description = "The tags applied to the key vaults."
  value       = var.tags
}

output "tenant_id" {
  description = "The tenant id the vaults are in."
  value       = local.tenant_id
}

output "vault_uris" {
  description = "Map of key vault name to its data-plane URI."
  value       = { for k, v in azurerm_key_vault.this : k => v.vault_uri }
}
