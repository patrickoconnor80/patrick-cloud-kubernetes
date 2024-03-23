resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio.metadata[0].name
  depends_on = [kubernetes_namespace.istio]
} 

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio.metadata[0].name
  # Reduce standard cpu and memory requests in half
  set {
    name = "pilot.resources.requests.memory"
    value = "512Mi"
  }
  set {
    name = "pilot.resources.requests.cpu"
    value = "400m"
  }
  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }
  depends_on       = [helm_release.istio_base]
}

resource "helm_release" "istio_gateway" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  force_update = true
  depends_on       = [helm_release.istiod]
}


resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "istio-ingress"
  }
}