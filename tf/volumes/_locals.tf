locals {
  prefix = "patrick-cloud-${var.env}"
  eks_node_group_subnet_ids = [for subnet in data.aws_subnet.eks_node_group : subnet.id]
  tags = {
    env        = var.env
    project    = "patrick-cloud"
    deployment = "terraform"
    repo       = "https://github.com/patrickoconnor80/patrick-cloud-kubernetes/tree/main/tf/volumes"
  }
}