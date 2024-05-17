## SECRURITY GROUP RULES ##

resource "aws_security_group_rule" "ray_cluster_egress" {
  security_group_id = data.aws_security_group.ray_cluster.id
  description       = "Allow all outbound traffic on Ray Cluster"
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ray_cluster_ingress_self" {
  security_group_id = data.aws_security_group.ray_cluster.id
  description       = "Allow all inbound traffic on Ray Cluster from iteself"
  type              = "ingress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  self = true
}

resource "aws_security_group_rule" "ray_cluster_ingress_local" {
  security_group_id = data.aws_security_group.ray_cluster.id
  description       = "Allow workstation to communicate with the ray cluster API Server"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["98.229.26.12/32"]
}

resource "aws_security_group_rule" "ray_cluster_ingress_eks_cluster" {
  security_group_id        = data.aws_security_group.ray_cluster.id
  description              = "Allow EKS Cluster to commmunitcate with Ray Cluster"
  type                     = "ingress"
  protocol                 = -1
  from_port                = 0
  to_port                  = 0
  source_security_group_id = data.aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "ray_cluster_ingress_eks_node_group" {
  security_group_id        = data.aws_security_group.ray_cluster.id
  description              = "Allow EKS Node Group to commmunitcate with Ray Cluster"
  type                     = "ingress"
  protocol                 = -1
  from_port                = 0
  to_port                  = 0
  source_security_group_id = data.aws_security_group.eks_node_group.id
}