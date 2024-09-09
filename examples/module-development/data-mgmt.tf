data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "mgmt_rg" {
  name = "rg-lbd-uks-prd-mgmt"
}

data "azurerm_user_assigned_identity" "mgmt_id" {
  name                = "id-lbd-uks-prd-mgmt-01"
  resource_group_name = data.azurerm_resource_group.mgmt_rg.name
}