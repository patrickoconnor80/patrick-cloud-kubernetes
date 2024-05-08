# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#
# Outputs
#

# locals {
#   config_map_aws_auth = <<CONFIGMAPAWSAUTH
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapRoles: |
#     - rolearn: ${data.aws_iam_role.eks_node.arn}
#       username: system:node:{{EC2PrivateDNSName}}
#       groups:
#         - system:bootstrappers
#         - system:nodes
# CONFIGMAPAWSAUTH

#   kubeconfig = <<KUBECONFIG
# apiVersion: v1
# clusters:
# - cluster:
#     server: ${aws_eks_cluster.this.endpoint}
#     certificate-authority-data: ${aws_eks_cluster.this.certificate_authority[0].data}
#   name: kubernetes
# contexts:
# - context:
#     cluster: kubernetes
#     user: aws
#   name: aws
# current-context: aws
# kind: Config
# preferences: {}
# users:
# - name: aws
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1beta1
#       command: aws-iam-authenticator
#       args:
#         - "token"
#         - "-i"
#         - "${local.cluster_name}"
# KUBECONFIG
# }

output "eks_cluster_name" {
  value = aws_eks_cluster.this.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "karpenter_queue_name" {
  value = module.karpenter.queue_name
}

output "karpenter_iam_role_arn" {
  value = module.karpenter.iam_role_arn
}