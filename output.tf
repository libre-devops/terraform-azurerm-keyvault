output "full_certificate_permissions" {
  description = "Full permissions to the certificate permission set, used as a variable in the module"
  value       = tolist(var.full_certificate_permissions)
}

output "full_key_permissions" {
  description = "Full permissions to the key permission set, used as a variable in the module"
  value       = tolist(var.full_key_permissions)
}

output "full_secret_permissions" {
  description = "Full permissions to the secret permission set, used as a variable in the module"
  value       = tolist(var.full_secret_permissions)
}

output "full_storage_permissions" {
  description = "Full permissions to the storage permission set, used as a variable in the module"
  value       = tolist(var.full_storage_permissions)
}

output "kv_id" {
  description = "The id of the keyvault"
  value       = azurerm_key_vault.keyvault.id
}

output "kv_name" {
  description = "The name of the keyvault"
  value       = azurerm_key_vault.keyvault.name
}

output "kv_tenant_id" {
  description = "The keyvault tenant id"
  value       = azurerm_key_vault.keyvault.tenant_id
}
