<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Key Vault

Key vaults with secure defaults: RBAC authorization, purge protection, and deny-by-default network ACLs.

[![CI](https://github.com/libre-devops/terraform-azurerm-keyvault/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-keyvault/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-keyvault?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-keyvault/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-keyvault)](./LICENSE)

---

## Overview

Key vaults keyed by name, secure by default: **RBAC authorization** (assign roles, not access
policies), **purge protection** on, a **90 day soft-delete** window, and a **deny-by-default network
ACL** (public endpoint reachable only from allow-listed IPs/subnets, with Azure services allowed to
bypass). `tenant_id` defaults to the caller's tenant. Legacy `access_policies` are supported when you
set `rbac_authorization_enabled = false`; set `public_network_access_enabled = false` and add a private
endpoint for full isolation. Perimeter/observability compose via the `diagnostic-settings` (ship vault
logs to Log Analytics) and `network-security-perimeter` modules. The resource group is passed by id.

> Purge protection prevents deleting a vault for the soft-delete retention period. It defaults **on**;
> set it to `false` for disposable/test vaults (as the examples do) so they can be torn down.

## Usage

```hcl
module "keyvault" {
  source  = "libre-devops/keyvault/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  key_vaults = {
    "kv-ldo-uks-prd-001" = {
      network_acls = {
        default_action = "Deny"
        ip_rules       = ["203.0.113.0/24"]
      }
    }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - a single vault with the secure defaults.
- [`examples/complete`](./examples/complete) - two vaults (one RBAC with a network allow-list and disk
  encryption, one using legacy access policies), with both vaults' logs shipped to a Log Analytics
  workspace via the `diagnostic-settings` module.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| AVD-AZU-0016 | Example vaults (`examples/*/main.tf`) | Purge protection not enabled | The examples disable purge protection so the disposable test vaults can be torn down. The module defaults purge protection to **on**; real vaults keep it. |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.
