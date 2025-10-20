resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name      = "postgres-config"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }

  data = {
    "postgresql.conf" = <<-EOF
      listen_address ='*'
      port = 5432
      max_connections=200
      shared_buffers=256MB
      effective_cache_size=1GB
      maintenance_work_mem=64MB
      checkpoint_completion_target=0.9
      wal_buffers=16MB
      default_statistics_target=100
      random_page_cost=1.1
      effective_io_concurrency=200
      work_mem=4MB
      huge_pages=off
      min_wal_size=2GB
      max_wal_size=8GB
    EOF

    "init.sql" = <<-EOF
      CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    EOF
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name        = "postgres-pvc"
    namespace   = kubernetes_namespace.postgres.metadata[0].name
    annotations = { "volume.beta.kubernetes.io/storage-class" = "azure-container-storage" }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "100Gi" }
    }
    storage_class_name = "azure-container-storage"
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.postgres.metadata[0].name
    labels    = { app = "postgres" }
  }
  spec {
    replicas     = 1
    service_name = "postgres"
    selector {
      match_labels = { app = "postgres" }
    }
    template {
      metadata {
        labels = { app = "postgres" }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:15"

          env {
            name  = "POSTGRES_DB"
            value = "fsdh"
          }
          env {
            name  = "POSTGRES_USER"
            value = "fsdhadmin"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "welcome1"
          }
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }
          port {
            name           = "postgres"
            container_port = 5432
          }
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
          volume_mount {
            name       = "postgres-config"
            mount_path = "/etc/postgresql.conf"
            sub_path   = "postgresql.conf"
          }
          volume_mount {
            name       = "postgres-init"
            mount_path = "/docker-entrypoint-initdb.d/init.sql"
            sub_path   = "init.sql"
          }
          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }
          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "fsdhadmin"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          readiness_probe {
            exec {
              command = ["pg_isready", "-U", "fsdhadmin"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "postgres-config"
          config_map {
            name = kubernetes_config_map.postgres_config.metadata[0].name
            items {
              key  = "postgresql.conf"
              path = "postgresql.conf"
            }
          }
        }
        volume {
          name = "postgres-init"
          config_map {
            name = kubernetes_config_map.postgres_config.metadata[0].name
            items {
              key  = "init.sql"
              path = "init.sql"
            }
          }
        }
      }
    }

    volume_claim_template {
      metadata { name = "postgres-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "100Gi"
          }
        }
        storage_class_name = "azure-container-storage"
      }
    }
  }
}



resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      name = "postgres"
    }
  }
}

# Kubernetes Secret for passwords (optional)
resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }

  data = {
    postgres-password = random_password.postgres_password.result
    app-user-password = random_password.app_user_password.result
  }

  depends_on = [kubernetes_namespace.postgres]
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    selector = { app = kubernetes_stateful_set.postgres.spec.0.template.0.metadata[0].labels.app }

    port {
      name        = "postgres"
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "postgres_external" {
  count = 0

  metadata {
    name      = "postgres-external"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    selector = { app = kubernetes_stateful_set.postgres.spec.0.template.0.metadata[0].labels.app }

    port {
      port        = 5432
      target_port = 5432
      node_port   = 30432
    }
    type = "NodePort"
  }
}
