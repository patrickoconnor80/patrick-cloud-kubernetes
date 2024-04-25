resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = data.aws_iam_role.eks_cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator","controllerManager","scheduler"]

  vpc_config {
    security_group_ids = [data.aws_security_group.eks_cluster.id]
    subnet_ids         = local.public_subnet_ids
    public_access_cidrs = [data.aws_vpc.this.cidr_block]
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
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow workstation to communicate with the cluster API Server"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [local.workstation-external-cidr]
}

##  CONSOLE ACCESS ##

# Create root as user in EKS
resource "aws_eks_access_entry" "root" {
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  user_name         = "root"
  type              = "STANDARD"
}

# Give root full cluster admin access
resource "aws_eks_access_policy_association" "root" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

  access_scope {
    type       = "cluster"
  }
}