resource "aws_iam_role" "monitoring_external_secrets_sa" {
  name        = "${local.prefix}-eks-monitoring-external-secrets-sa-role"
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
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" : "system:serviceaccount:monitoring:external-secrets-sa",
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "monitoring_external_secrets_sa" {
  name        = "${local.prefix}-eks-monitoring-external-secrets-sa-policy"
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
        Resource = data.aws_secretsmanager_secret.grafana_credentials.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets_sa" {
  policy_arn = aws_iam_policy.monitoring_external_secrets_sa.arn
  role       = aws_iam_role.monitoring_external_secrets_sa.name
}