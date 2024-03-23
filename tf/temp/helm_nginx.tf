# resource "helm_release" "nginx" {
#   name       = "nginx"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx"
#   #namespace  = kubernetes_namespace.nginx.metadata[0].name
#   values = [
#     file("${path.module}/../cfg/nginx-values.yaml")
#   ]
# }

# output "nginx_endpoint" {
#     value = "http://${kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.hostname}"
# }