data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "golden_vpc" {
  filter {
    name   = "tag:Name"
    values = ["golden-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["golden-vpc-public-us-east-1*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["golden-vpc-private-us-east-1*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_secretsmanager_secret" "grafana_credentials" {
  name = "GRAFANA_CREDENTIALS"
}