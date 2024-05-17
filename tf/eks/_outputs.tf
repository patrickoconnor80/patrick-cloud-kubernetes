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

output "karpenter_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}