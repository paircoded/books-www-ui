resource "kubernetes_service" "books_www_ui" {
  metadata {
    name      = "books-www-ui"
    namespace = "paircoded"
    labels = {
      AppName = "books-www-ui"
    }
  }

  spec {
    selector = {
      AppName = kubernetes_deployment.books_www_ui.metadata.0.labels.AppName
    }
    session_affinity = "ClientIP"
    port {
      name = "nginx"
      port        = 80
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "books_www_ui" {
  wait_for_load_balancer = true
  metadata {
    name      = "books-www-ui"
    namespace = "paircoded"
    labels = {
      AppName = "books-www-ui"
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts      = [
        "books.paircoded.com",
      ]
      secret_name = "wildcard-paircoded-com"
    }

    rule {
      host = "books.paircoded.com"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.books_www_ui.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "books_www_ui" {
  metadata {
    name      = "books-www-ui"
    namespace = "paircoded"
    labels = {
      AppName = "books-www-ui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        AppName = "books-www-ui"
      }
    }

    template {
      metadata {
        namespace = "paircoded"
        name      = "books-www-ui"
        labels = {
          AppName = "books-www-ui"
        }
      }

      spec {
        container {
          image = "docker-registry.poorlythoughtout.com/olis-restful-json-api:${var.image_tag}"
          name  = "books-www-ui"
        }
      }
    }
  }
}
