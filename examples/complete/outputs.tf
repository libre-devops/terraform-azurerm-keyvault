output "diagnostic_setting_ids" {
  description = "The diagnostic setting ids shipping vault logs to the workspace."
  value       = module.diagnostics.diagnostic_setting_ids
}

output "key_vault_ids" {
  description = "Map of key vault name to resource id."
  value       = module.keyvault.ids
}

output "tags" {
  description = "The tags applied to the resources."
  value       = module.tags.tags
}

output "vault_uris" {
  description = "Map of key vault name to data-plane URI."
  value       = module.keyvault.vault_uris
}
