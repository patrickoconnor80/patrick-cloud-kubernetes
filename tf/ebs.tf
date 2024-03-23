resource "aws_ebs_volume" "grafana" {
  availability_zone = "us-east-1b"
  size              = 2
  type = "gp2"
  tags = {
    Name = "${local.prefix}-eks-grafana-pv"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ebs_volume" "prometheus_server" {
  availability_zone = "us-east-1b"
  size              = 8
  type = "gp2"
  tags = {
    Name = "${local.prefix}-eks-prometheus-server-pv"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ebs_volume" "alert_manager_prometheus" {
  availability_zone = "us-east-1b"
  size              = 2
  type = "gp2"
  tags = {
    Name = "${local.prefix}-eks-alert-manager-prometheus-pv"
  }
  lifecycle {
    prevent_destroy = true
  }
}