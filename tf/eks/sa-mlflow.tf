resource "aws_iam_role" "mlflow_sa" {
  name        = "${local.prefix}-eks-mlflow-sa-role"
  description = "AWS IAM Role for the Kubernetes service account mflow-sa."
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
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" : "system:serviceaccount:mlflow:mlflow-sa",
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "mlflow_sa" {
  name        = "${local.prefix}-eks-mlflow-sa-policy"
  description = "Give EKS Service Account - sa access to EKS specific secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3"
        Effect = "Allow"
        Action = [
          "s3:List*",
          "s3:Get*",
          "s3:Describe*",
          "s3:Put*",
          "s3:DeleteObject*",
          "s3:Tag"
        ]
        Resource = [
            "arn:aws:s3:::${local.prefix}-mlflow-artifact-root",
            "arn:aws:s3:::${local.prefix}-mlflow-artifact-root/*"
        ]
      },
      {
        Sid    = "RDS"
        Effect = "Allow"
        Action = [
          "rds-db:connect",
          "s3:Get*",
          "s3:Describe*",
          "s3:Put*",
          "s3:DeleteObject*",
          "s3:Tag"
        ]
        Resource = [
            "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${local.prefix}-mlflow-db:postgres"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mlflow_sa" {
  policy_arn = aws_iam_policy.mlflow_sa.arn
  role       = aws_iam_role.mlflow_sa.name
}

# Policy found at patrick-cloud-machine-learning/tf/mlflow/rds.tf:aws_iam_policy.rds_access
resource "aws_iam_role_policy_attachment" "mlflow_rds_access" {
  policy_arn = data.aws_iam_policy.mlflow_rds_access.arn
  role       = aws_iam_role.mlflow_sa.name
}

# Policy found at patrick-cloud-machine-learning/tf/mlflow/s3.tf:aws_iam_policy.kms_decrypt_s3_bucket
resource "aws_iam_role_policy_attachment" "mlflow_s3_kms_access" {
  policy_arn = data.aws_iam_policy.mlflow_s3_kms_access.arn
  role       = aws_iam_role.mlflow_sa.name
}