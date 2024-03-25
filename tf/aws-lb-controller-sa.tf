resource "aws_iam_role" "aws_lb_controller_sa" {
  name        = "${local.prefix}-eks-aws-lb-controller-sa-role"
  description = "AWS IAM Role for the Kubernetes service account aws-lb-controller-sa."
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
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-lb-controller-sa",
            "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "aws_lb_controller_sa" {                                                                                                       
    policy = file("templates/aws_load_balancer_controller_policy.json")         
} 

# Give read only access to application-autoscaling, autoscaling, cloudwatch, logs, oam, sns, rum, syntehtics, xray
resource "aws_iam_role_policy_attachment" "aws_lb_controller_sa" {
  policy_arn = aws_iam_policy.aws_lb_controller_sa.arn
  role       = aws_iam_role.aws_lb_controller_sa.name
}