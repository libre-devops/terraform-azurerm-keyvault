output "client_access_policy_certificate_permissions" {
  description = "The key permissions of the client access policy."
  value       = length(azurerm_key_vault_access_policy.client_access) > 0 ? azurerm_key_vault_access_policy.client_access[0].certificate_permissions : null
}

output "client_access_policy_id" {
  description = "The ID of the client access policy."
  value       = length(azurerm_key_vault_access_policy.client_access) > 0 ? azurerm_key_vault_access_policy.client_access[0].id : null
}

output "client_access_policy_key_permissions" {
  description = "The key permissions of the client access policy."
  value       = length(azurerm_key_vault_access_policy.client_access) > 0 ? azurerm_key_vault_access_policy.client_access[0].key_permissions : null
}

output "client_access_policy_secret_permissions" {
  description = "The key permissions of the client access policy."
  value       = length(azurerm_key_vault_access_policy.client_access) > 0 ? azurerm_key_vault_access_policy.client_access[0].secret_permissions : null
}

output "key_vault_ids" {
  description = "The IDs of the created Key Vaults."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : vault => key_vault.id }
}

output "key_vault_locations" {
  description = "The locations of the created Key Vaults."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : vault => key_vault.location }
}

output "key_vault_names" {
  description = "The names of the created Key Vaults."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : vault => key_vault.name }
}

output "key_vault_uris" {
  description = "The uris of the created Key Vaults."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : vault => key_vault.vault_uri }
}
