resource "kubernetes_network_policy" "postgres_network_policy" {
  metadata {
    name      = "postgres-network-policy"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = { app = "postgres" }
    }
    policy_types = ["Ingress"]

    ingress {
      ports {
        port     = "5432"
        protocol = "TCP"
      }
      from {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }
    }
  }
}

# resource "azurerm_network_security_rule" "postgres_ingress" {
#   name                        = "postgres-from-internet"
#   priority                    = 1001
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "5432"
#   source_address_prefix       = "0.0.0.0/0"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_kubernetes_cluster.datahub_aks.resource_group_name
#   network_security_group_name = azurerm_kubernetes_cluster.datahub_aks.default_node_pool[0]
# }
