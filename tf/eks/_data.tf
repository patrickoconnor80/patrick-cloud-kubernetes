data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-vpc"]
  }
}

data "aws_subnets" "eks_control_plane" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-eks-control-plane-us-east-1*"]
  }
}

data "aws_subnet" "eks_control_plane" {
  for_each = toset(data.aws_subnets.eks_control_plane.ids)
  id       = each.value
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

data "aws_subnets" "ray" {
  filter {
    name   = "tag:Name"
    values = ["${local.prefix}-eks-ray-cluster-us-east-1*"]
  }
}

data "aws_subnet" "ray" {
  for_each = toset(data.aws_subnets.ray.ids)
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

data "aws_secretsmanager_secret" "mlflow_tracking_uri" {
  name = "MLFLOW_TRACKING_URI"
}

data "aws_secretsmanager_secret" "mlflow_tracking_password" {
  name = "MLFLOW_TRACKING_PASSWORD"
}

data "aws_iam_policy" "databricks_workspace_secrets_kms_access" {
  name = "${local.prefix}-dataricks-workspace-secrets-kms-access"
}

data "aws_iam_policy" "databricks_account_secrets_kms_access" {
  name = "${local.prefix}-dataricks-account-secrets-kms-access"
}

data "aws_iam_policy" "mlflow_secrets_kms_access" {
  name = "${local.prefix}-mlflow-kms-decrypt-secrets-access"
}

data "aws_iam_policy" "mlflow_s3_kms_access" {
  name = "${local.prefix}-mlflow-kms-decrypt-s3-bucket-policy"
}

data "aws_iam_policy" "mlflow_rds_access" {
  name = "${local.prefix}-mlflow-rds-access-policy"
}

data "aws_iam_role" "eks_cluster" {
  name = "${local.prefix}-eks-cluster-role"
}

data "aws_iam_role" "eks_node" {
  name = "${local.prefix}-eks-node-role"
}

data "aws_security_group" "eks_cluster" {
  name = "${local.prefix}-eks-cluster-sg"
}

data "aws_security_group" "eks_node_group" {
  tags = {
    "kubernetes.io/cluster/${local.prefix}-eks-cluster" = "owned"
  }
  depends_on = [aws_eks_cluster.this]
}

data "aws_security_group" "jenkins" {
  name = "${local.prefix}-jenkins-sg"
}

data "aws_security_group" "ray_cluster" {
  name = "${local.prefix}-ray-cluster-sg"
}