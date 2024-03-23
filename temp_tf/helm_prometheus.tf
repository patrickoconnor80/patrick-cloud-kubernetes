# resource "helm_release" "kube_prometheus_stack" {
#   name       = "kube-prometheus-stack"
#   namespace = kubernetes_namespace.monitoring.metadata[0].name
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   values = [
#     file("${path.module}/../cfg/prometheus_values.yaml")
#   ]
#   depends_on = [helm_release.istiod]
# }

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  values = [
    file("${path.module}/../cfg/prometheus_values.yaml")
  ]
  depends_on = [helm_release.istiod]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  values = [
    file("${path.module}/../cfg/grafana_values.yaml")
  ]
  depends_on = [helm_release.istiod]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      mylabel = "monitoring"
      istio-injection = "enabled"
    }
    name = "monitoring"
  }
}

resource "kubernetes_storage_class" "ebs-gp2-sc" {
  metadata {
    name = "ebs-gp2-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp2"
  }
}


# resource "kubernetes_api_service" "prometheus" {
#   metadata {
#     name = "prometheus-load-balancer"
#   }
#   spec {
#     selector {
#       app = "${helm_release.kube_prometheus_stack.manifest.0.labels.app}"
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 8080
#       target_port = 9090
#     }

#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_api_service" "grafana" {
#   metadata {
#     name = "prometheus-load-balancer"
#   }
#   spec {
#     selector {
#       app = "${helm_release.kube_prometheus_stack.metadata.values.labels.app}"
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 8080
#       target_port = 3000
#     }

#     type = "LoadBalancer"
#   }
# }