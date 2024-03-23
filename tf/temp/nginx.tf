# resource "kubernetes_deployment" "nginx" {
#   metadata {
#     name = "scalable-nginx-example"
#     labels = {
#       App = "ScalableNginxExample"
#     }
#   }

#   spec {
#     replicas = 4
#     selector {
#       match_labels = {
#         App = "ScalableNginxExample"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           App = "ScalableNginxExample"
#         }
#       }
#       spec {
#         container {
#           image = "nginx:1.7.8"
#           name  = "example"

#           port {
#             container_port = 80
#           }

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#         }
#       }
#     }
#   }
# }


# resource "kubernetes_service" "nginx" {
#   metadata {
#     name = "nginx-example"
#     labels = {
#         environment = "dev"
#         app = "nginx"
#     }
#     namespace = kubernetes_namespace.nginx.metadata[0].name
#   }
#   spec {
#     selector = {
#       App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_namespace" "nginx" {
#   metadata {
#     labels = {
#       mylabel = "nginx"
#     }
#     name = "nginx-namespace"
#   }
# }