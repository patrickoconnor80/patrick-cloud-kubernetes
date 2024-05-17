data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-vpc"]
  }
}

data "aws_subnets" "eks_node_group" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-eks-node-group-us-east-1b*"]
  }
}

data "aws_subnet" "eks_node_group" {
  for_each = toset(data.aws_subnets.eks_node_group.ids)
  id       = each.value
}