output "client_access_policy_certificate_permissions" {
  description = "The certificate permissions of the client access policy, keyed by Key Vault name."
  value       = { for vault, policy in azurerm_key_vault_access_policy.client_access : vault => policy.certificate_permissions }
}

output "client_access_policy_id" {
  description = "The ID of the client access policy, keyed by Key Vault name."
  value       = { for vault, policy in azurerm_key_vault_access_policy.client_access : vault => policy.id }
}

output "client_access_policy_key_permissions" {
  description = "The key permissions of the client access policy, keyed by Key Vault name."
  value       = { for vault, policy in azurerm_key_vault_access_policy.client_access : vault => policy.key_permissions }
}

output "client_access_policy_secret_permissions" {
  description = "The secret permissions of the client access policy, keyed by Key Vault name."
  value       = { for vault, policy in azurerm_key_vault_access_policy.client_access : vault => policy.secret_permissions }
}

output "key_vault_ids" {
  description = "The IDs of the created Key Vaults, keyed by vault name."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : key_vault.name => key_vault.id }
}

output "key_vault_locations" {
  description = "The locations of the created Key Vaults, keyed by vault name."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : key_vault.name => key_vault.location }
}

output "key_vault_names" {
  description = "The names of the created Key Vaults, keyed by vault name."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : key_vault.name => key_vault.name }
}

output "key_vault_uris" {
  description = "The uris of the created Key Vaults, keyed by vault name."
  value       = { for vault, key_vault in azurerm_key_vault.keyvault : key_vault.name => key_vault.vault_uri }
}
