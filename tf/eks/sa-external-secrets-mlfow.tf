resource "aws_iam_role" "mlflow_external_secrets_sa" {
  name        = "${local.prefix}-eks-mlflow-external-secrets-sa-role"
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
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" : "system:serviceaccount:mlflow:external-secrets-sa",
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "mlflow_external_secrets_sa" {
  name        = "${local.prefix}-eks-mlflow-external-secrets-sa-policy"
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
          data.aws_secretsmanager_secret.mlflow_tracking_uri.arn,
          data.aws_secretsmanager_secret.mlflow_tracking_password.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mlflow_external_secrets_sa" {
  policy_arn = aws_iam_policy.mlflow_external_secrets_sa.arn
  role       = aws_iam_role.mlflow_external_secrets_sa.name
}

# Policy found at patrick-cloud-machine-learning/tf/mlflow/secrets_manager.tf:aws_iam_policy.secrets_kms_access
resource "aws_iam_role_policy_attachment" "mlflow_secrets_kms_access" {
  policy_arn = data.aws_iam_policy.mlflow_secrets_kms_access.arn
  role       = aws_iam_role.mlflow_external_secrets_sa.name
}