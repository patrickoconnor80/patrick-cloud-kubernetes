#---------------------------------------------------------------
# Karpenter Infrastructure
# Outputs:
#   - Karpenter Controller IAM Role(IRSA)
#   - Node Termination SQS Queue
#   - Node Termination Eventbridge Rules
#   - Node IAM Role
#   - Node IAM Instance Profile
#---------------------------------------------------------------

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.8.5"

  cluster_name           = local.cluster_name
  irsa_oidc_provider_arn = aws_iam_openid_connect_provider.this.arn
  node_iam_role_additional_policies = {
    additional_policy = module.karpenter_policy.arn
  }
  iam_role_name = "${local.prefix}-eks-karp-controller"
  node_iam_role_name = "${local.prefix}-eks-karpenter-node"

  tags = local.tags
}

# We have to augment default the karpenter node IAM policy with
# permissions we need for Ray Jobs to run until IRSA is added
# upstream in kuberay-operator. See issue
# https://github.com/ray-project/kuberay/issues/746
module "karpenter_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.20"

  name        = "KarpenterS3ReadOnlyPolicy"
  description = "IAM Policy to allow read from an S3 bucket for karpenter nodes"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "ListObjectsInBucket"
          Effect   = "Allow"
          Action   = ["s3:ListBucket"]
          Resource = ["arn:aws:s3:::air-example-data-2"]
        },
        {
          Sid      = "AllObjectActions"
          Effect   = "Allow"
          Action   = "s3:Get*"
          Resource = ["arn:aws:s3:::air-example-data-2/*"]
        }
      ]
    }
  )
}


