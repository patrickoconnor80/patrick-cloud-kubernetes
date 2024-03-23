locals {
  price       = var.price == "yes" ? 1 : 0
  prefix      = "patrick-cloud"
  public_subnet_ids = [for subnet in data.aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
  cluster_name = "${local.prefix}-eks-cluster"
}