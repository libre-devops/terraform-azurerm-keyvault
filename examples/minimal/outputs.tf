output "key_vault_ids" {
  description = "Map of key vault name to resource id."
  value       = module.keyvault.ids
}

output "vault_uris" {
  description = "Map of key vault name to data-plane URI."
  value       = module.keyvault.vault_uris
}
