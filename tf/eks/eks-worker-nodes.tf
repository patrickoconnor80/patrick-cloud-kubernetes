resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.prefix}-default-node-group"
  node_role_arn   = data.aws_iam_role.eks_node.arn
  subnet_ids      = [
    local.eks_node_group_subnet_ids[0] # Keep to 1 AZ so PV's don't have to be spread across AZs - us-east-1b
  ] 

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.xlarge"]

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = local.tags
}

resource "aws_autoscaling_group_tag" "default" {    
  autoscaling_group_name = aws_eks_node_group.default.resources[0].autoscaling_groups[0].name

  tag {
    key   = "Name"
    value = "eks-default-node-group-instance"

    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.default
  ]
}

## IAM POLCIY ATTACHMENTS ##

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = data.aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = data.aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = data.aws_iam_role.eks_node.name
}