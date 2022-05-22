variable "enable_rbac_authorization" {
  type        = bool
  description = "Whether key vault access policy or Azure rbac is used, default is false as the key vault access policy is the default behavior for this module"
  default     = false
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Enable this keyvault for template deployments access"
  default     = true
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "If this keyvault is enabled for disk encryption"
  default     = true
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "If this keyvault is enabled for ARM template deployments"
  default     = true
}

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
  default     = true
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "kv_name" {
  type        = string
  description = "The name of the keyvault"
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "purge_protection_enabled" {
  type        = bool
  description = "If purge protection is enabled, for automation, it is recomended to be disabled so you can delete it, but for security, it should be enabled.  defaults to false to"
  default     = false
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "settings" {
  type        = any
  description = "A map used for the settings blocks"
  default     = {}
}

variable "sku_name" {
  type        = string
  description = "The sku of your keyvault, defaults to standard"
  default     = "Standard"
}

variable "soft_delete_retention_days" {
  type        = number
  description = "The number of days for soft delete, defaults to 7 the minimum"
  default     = 7
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "tenant_id" {
  type        = string
  description = "If you are not using current client_config, set tenant id here"
  default     = null
}

variable "use_current_client" {
  type        = bool
  description = "If you wish to use the current client config or not"
}
