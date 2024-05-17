resource "aws_eks_cluster" "this" {
  name                      = local.cluster_name
  role_arn                  = data.aws_iam_role.eks_cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids      = [data.aws_security_group.eks_cluster.id]
    subnet_ids              = local.eks_control_plane_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["98.229.26.12/32"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]

  tags = local.tags
}

resource "null_resource" "login_eks_locally" {

  provisioner "local-exec" {
    command = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${aws_eks_cluster.this.name}"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [aws_eks_cluster.this]
}


## IAM POLCIY ATTACHMENTS ##

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = data.aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = data.aws_iam_role.eks_cluster.name
}


## SECRURITY GROUP RULES ##

resource "aws_security_group_rule" "egress" {
  security_group_id = data.aws_security_group.eks_cluster.id
  description       = "Allow all outbound traffic on EKS"
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_local" {
  security_group_id = data.aws_security_group.eks_cluster.id
  description       = "Allow workstation to communicate with the cluster API Server"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["98.229.26.12/32"]
}

resource "aws_security_group_rule" "ingress_jenkins" {
  security_group_id        = data.aws_security_group.eks_cluster.id
  description              = "Allow jenkins to communicate with the cluster API Server"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = data.aws_security_group.jenkins.id
}

resource "aws_security_group_rule" "ingress_ray_cluster" {
  security_group_id        = data.aws_security_group.eks_node_group.id
  description              = "Allow Ray Cluster to commmunitcate with EKS Node Group"
  type                     = "ingress"
  protocol                 = -1
  from_port                = 0
  to_port                  = 0
  source_security_group_id = data.aws_security_group.ray_cluster.id
}

## CONSOLE ACCESS ##

# Create root as user in EKS
resource "aws_eks_access_entry" "console_root" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  user_name     = "root_console"
  type          = "STANDARD"
}

# Give root full cluster admin access
resource "aws_eks_access_policy_association" "console" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

  access_scope {
    type = "cluster"
  }
}


## CLI ACCESS ##

# resource "aws_eks_access_entry" "cli_root" {
#   cluster_name  = aws_eks_cluster.this.name
#   principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/root-aws-cli"
#   user_name     = "root_cli"
#   type          = "STANDARD"
# }

# resource "aws_eks_access_policy_association" "cli" {
#   cluster_name  = aws_eks_cluster.this.name
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/root-aws-cli"

#   access_scope {
#     type = "cluster"
#   }
# }

resource "aws_eks_access_entry" "jenkins" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.prefix}-jenkins-ec2-role"
  user_name     = "jenkins"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "jenkins" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.prefix}-jenkins-ec2-role"

  access_scope {
    type = "cluster"
  }
}

# resource "aws_eks_access_entry" "ray_cluster" {
#   cluster_name  = aws_eks_cluster.this.name
#   principal_arn = module.karpenter.node_iam_role_arn
#   user_name     = "ray_cluster"
#   type          = "STANDARD"
# }

# resource "aws_eks_access_policy_association" "ray_cluster" {
#   cluster_name  = aws_eks_cluster.this.name
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   principal_arn = module.karpenter.node_iam_role_arn

#   access_scope {
#     type = "cluster"
#   }
# }