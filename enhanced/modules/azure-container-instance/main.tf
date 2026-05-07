resource "azurerm_container_group" "proj_container_instance" {
  name                = "${local.base_name}-aci"
  location            = var.az_location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  dns_name_label      = "${local.base_name}-aci"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
    cpu    = "1"
    memory = "2"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = var.project_tags

  lifecycle {
    ignore_changes  = [tags]
  }
}
