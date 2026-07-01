variable "key_vaults" {
  description = <<-EOT
    Key vaults to create, keyed by vault name. Secure defaults: RBAC authorization on (assign roles
    rather than access policies), purge protection on, a 90 day soft-delete window, and a deny-by-default
    network ACL (public endpoint reachable only from allow-listed IPs/subnets, Azure services bypass).

    Set rbac_authorization_enabled = false to use legacy access_policies. Set public_network_access_enabled
    = false and add a private endpoint separately for full isolation. NOTE: purge protection prevents
    deletion for the soft-delete retention period, so disposable/test vaults should set it to false.
  EOT
  type = map(object({
    sku_name                        = optional(string, "standard")
    rbac_authorization_enabled      = optional(bool, true)
    purge_protection_enabled        = optional(bool, true)
    soft_delete_retention_days      = optional(number, 90)
    public_network_access_enabled   = optional(bool, true)
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)

    network_acls = optional(object({
      default_action             = optional(string, "Deny")
      bypass                     = optional(string, "AzureServices")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), {})

    access_policies = optional(list(object({
      object_id               = string
      tenant_id               = optional(string)
      application_id          = optional(string)
      key_permissions         = optional(list(string), [])
      secret_permissions      = optional(list(string), [])
      certificate_permissions = optional(list(string), [])
      storage_permissions     = optional(list(string), [])
    })), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for v in values(var.key_vaults) : contains(["standard", "premium"], v.sku_name)])
    error_message = "Each key vault sku_name must be standard or premium."
  }

  validation {
    condition     = alltrue([for v in values(var.key_vaults) : v.soft_delete_retention_days >= 7 && v.soft_delete_retention_days <= 90])
    error_message = "Each key vault soft_delete_retention_days must be between 7 and 90."
  }

  validation {
    condition     = alltrue([for v in values(var.key_vaults) : v.network_acls == null ? true : contains(["Allow", "Deny"], v.network_acls.default_action)])
    error_message = "network_acls.default_action must be Allow or Deny."
  }
}

variable "location" {
  description = "Azure region for the key vaults."
  type        = string
}

variable "resource_group_id" {
  description = "Resource id of the resource group to create the key vaults in. The name and subscription are parsed from it (pass the rg module's ids output)."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "tags" {
  description = "Tags to apply to the key vaults."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Azure AD tenant id for the vaults. Defaults to the caller's tenant."
  type        = string
  default     = null
}
