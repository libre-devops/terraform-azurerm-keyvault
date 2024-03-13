variable "full_certificate_permissions" {
  type        = list(string)
  description = "All the available permissions for key access"
  default = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]
}

variable "full_key_permissions" {
  type        = list(string)
  description = "All the available permissions for key access"
  default = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey"
  ]
}

variable "full_secret_permissions" {
  type        = list(string)
  description = "All the available permissions for key access"
  default = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
}

variable "full_storage_permissions" {
  type        = list(string)
  description = "All the available permissions for key access"
  default = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

variable "give_current_client_full_access" {
  type        = bool
  description = "If you use your current client as the tenant id, do you wish to give it full access to the keyvault? this aids automation, and is thus enable by default for this module.  Disable for better security by setting to false"
  default     = false
}

variable "key_vaults" {
  description = "A list of key vaults to create"
  type = list(object({
    name                            = string
    location                        = string
    rg_name                         = string
    sku_name                        = optional(string, "standard")
    tenant_id                       = optional(string)
    enabled_for_deployment          = optional(bool, true)
    enabled_for_disk_encryption     = optional(bool, true)
    enabled_for_template_deployment = optional(bool, true)
    soft_delete_retention_days      = optional(number)
    public_network_access_enabled   = optional(bool)
    enable_rbac_authorization       = optional(bool, true)
    purge_protection_enabled        = optional(bool, false) # Easier for automation
    access_policy = optional(list(object({
      tenant_id           = string
      object_id           = string
      key_permissions     = list(string)
      secret_permissions  = list(string)
      storage_permissions = list(string)
    })))
    network_acls = optional(object({
      bypass                     = string
      default_action             = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    }))
    contact = optional(list(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })))
    tags = map(string)
  }))
  default = []
}

variable "use_current_client" {
  type        = bool
  description = "If you wish to use the current client config or not"
  default     = true
}
