resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = terraform.workspace
  }
}

resource "kubernetes_deployment_v1" "app" {
  depends_on = [kubernetes_namespace_v1.env]
  metadata {
    name      = "devops-app"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
    labels = {
      app = "devops"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "devops"
      }
    }

    template {
      metadata {
        labels = {
          app = "devops"
        }
      }

      spec {
        container {
          name  = "devops-container"
          image = "naveen266/devops-app:${var.image_tag}"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "app" {
  depends_on = [kubernetes_deployment_v1.app]
  metadata {
    name = "devops-service"
    namespace = kubernetes_namespace_v1.env.metadata[0].name
  }

  spec {

    selector = {
      app = "devops"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "NodePort"
  }
}