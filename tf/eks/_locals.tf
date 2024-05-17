locals {
  prefix             = "patrick-cloud-${var.env}"
  eks_control_plane_subnet_ids  = [for subnet in data.aws_subnet.eks_control_plane : subnet.id]
  eks_node_group_subnet_ids = [for subnet in data.aws_subnet.eks_node_group : subnet.id]
  eks_ray_subnet_ids  = [for subnet in data.aws_subnet.ray : subnet.id]
  cluster_name       = "${local.prefix}-eks-cluster"
  tags = {
    Env        = var.env
    Project    = "patrick-cloud"
    Deployment = "terraform"
    Repo       = "https://github.com/patrickoconnor80/patrick-cloud-machine-learning/tree/main/tf"
  }
}