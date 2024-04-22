resource "aws_iam_role" "cloudwatch_readonly_sa" {
  name        = "${local.prefix}-eks-cloudwatch-readonly-sa-role"
  description = "AWS IAM Role for the Kubernetes service account cloudwatch-readonly-sa."
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
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" : "system:serviceaccount:monitoring:cloudwatch-readonly-sa",
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Give read only access to application-autoscaling, autoscaling, cloudwatch, logs, oam, sns, rum, syntehtics, xray
resource "aws_iam_role_policy_attachment" "CloudWatchReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.cloudwatch_readonly_sa.name
}

# Give read only access to ec2, tag
resource "aws_iam_policy" "cloudwatch_readonly_sa" {
  name        = "${local.prefix}-eks-cloudwatch-readonly-sa-policy"
  description = "Give EKS Service Account - cloudwatch-readonly-sa access to AWS Cloudwatch to pull metrics"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowReadingFromEC2andTags"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "tag:GetResources"
        ]
        Resource = "*"
      }
    ]
  })
  #checkov:skip=CKV_AWS_355:Not too permissive
}

resource "aws_iam_role_policy_attachment" "cloudwatch_readonly_sa" {
  policy_arn = aws_iam_policy.cloudwatch_readonly_sa.arn
  role       = aws_iam_role.cloudwatch_readonly_sa.name
}