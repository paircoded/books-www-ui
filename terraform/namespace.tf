
data "kubernetes_namespace" "paircoded" {
  metadata {
    name = "paircoded"
  }
}
