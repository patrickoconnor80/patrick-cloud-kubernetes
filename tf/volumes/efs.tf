resource "aws_efs_file_system" "efs" {
  encrypted = true

  tags = local.tags
}

resource "aws_efs_mount_target" "efs_mt" {

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = local.eks_node_group_subnet_ids[0]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${local.prefix}-eks-efs"
  description = "Allow inbound NFS traffic from private subnets of the VPC"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "Allow NFS 2049/tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }

  tags = local.tags
}