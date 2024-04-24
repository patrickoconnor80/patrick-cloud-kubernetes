resource "aws_iam_role" "dbt_external_secrets_sa" {
  name        = "${local.prefix}-eks-dbt-external-secrets-sa-role"
  description = "AWS IAM Role for the Kubernetes service account external-secrets-sa."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.this.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" : "system:serviceaccount:dbt:external-secrets-sa",
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "dbt_external_secrets_sa" {
  name        = "${local.prefix}-eks-dbt-external-secrets-sa-policy"
  description = "Give EKS Service Account - external-secrets-sa access to EKS specific secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EKSGetSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:List*",
          "secretsmanager:Get*",
          "secretsmanager:Describe*"
        ]
        Resource = [
          data.aws_secretsmanager_secret.databricks_token.arn,
          data.aws_secretsmanager_secret.databricks_host.arn,
          data.aws_secretsmanager_secret.databricks_sql_endpoint.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_external_secrets_sa" {
  policy_arn = aws_iam_policy.dbt_external_secrets_sa.arn
  role       = aws_iam_role.dbt_external_secrets_sa.name
}

# Policy found at patrick-cloud-databricks/tf/account/secrets_manager.tf:aws_iam_policy.secrets_kms_access
resource "aws_iam_role_policy_attachment" "databricks_account_secrets_kms_access" {
  policy_arn = data.aws_iam_policy.databricks_account_secrets_kms_access.arn
  role       = aws_iam_role.dbt_external_secrets_sa.name
}

# Policy found at patrick-cloud-databricks/tf/workspace/secrets_manager.tf:aws_iam_policy.secrets_kms_access
resource "aws_iam_role_policy_attachment" "databricks_workspace_secrets_kms_access" {
  policy_arn = data.aws_iam_policy.databricks_workspace_secrets_kms_access.arn
  role       = aws_iam_role.dbt_external_secrets_sa.name
}