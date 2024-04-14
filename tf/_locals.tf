locals {
  prefix      = "patrick-cloud-${var.env}"
  public_subnet_ids = [for subnet in data.aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
  cluster_name = "${local.prefix}-eks-cluster"
      tags = {
        env        = var.env
        project       = "patrick-cloud"
        deployment = "terraform"
        repo = "https://github.com/patrickoconnor80/patrick-cloud-kubernetes/tree/main/tf"
    }
}