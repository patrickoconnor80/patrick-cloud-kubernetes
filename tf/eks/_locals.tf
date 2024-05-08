locals {
  prefix             = "patrick-cloud-${var.env}"
  public_subnet_ids  = [for subnet in data.aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
  public_1b_subnet_ids  = [for subnet in data.aws_subnet.public_1b : subnet.id]
  cluster_name       = "${local.prefix}-eks-cluster"
  tags = {
    Env        = var.env
    Project    = "patrick-cloud"
    Deployment = "terraform"
    Repo       = "https://github.com/patrickoconnor80/patrick-cloud-machine-learning/tree/main/tf"
  }
}