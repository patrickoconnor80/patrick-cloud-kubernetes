data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-public-us-east-1*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-private-us-east-1*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_secretsmanager_secret" "grafana_credentials" {
  name = "GRAFANA_CREDENTIALS"
}

data "aws_secretsmanager_secret" "databricks_token" {
  name = "DATABRICKS_TOKEN_"
}

data "aws_secretsmanager_secret" "databricks_sql_endpoint" {
  name = "DATABRICKS_SQL_ENDPOINT"
}

data "aws_secretsmanager_secret" "databricks_host" {
  name = "DATABRICKS_HOST"
}

data "aws_iam_policy" "databricks_workspace_secrets_kms_access" {
  name = "${local.prefix}-dataricks-workspace-secrets-kms-access"
}

data "aws_iam_policy" "databricks_account_secrets_kms_access" {
  name = "${local.prefix}-dataricks-account-secrets-kms-access"
}