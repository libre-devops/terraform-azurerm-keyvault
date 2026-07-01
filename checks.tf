# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# The module does nothing without at least one key vault.
check "has_key_vaults" {
  assert {
    condition     = length(var.key_vaults) > 0
    error_message = "No key_vaults were supplied, so this module creates nothing."
  }
}

# A deny-by-default network ACL is the secure baseline; warn if one is opened up to Allow.
check "network_acls_default_deny" {
  assert {
    condition = alltrue([
      for v in values(var.key_vaults) : v.network_acls == null ? true : v.network_acls.default_action == "Deny"
    ])
    error_message = "A key vault has network_acls.default_action = Allow, which permits all networks. Prefer Deny with explicit ip_rules / virtual_network_subnet_ids, or a private endpoint."
  }
}
