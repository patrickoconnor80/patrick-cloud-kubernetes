resource "aws_eks_identity_provider_config" "demo" {
  cluster_name = aws_eks_cluster.this.name
  oidc {
    client_id = "${substr(aws_eks_cluster.this.identity.0.oidc.0.issuer, -32, -1)}"
    identity_provider_config_name = "${local.prefix}-identity-provider-config-name"
    issuer_url = "https://${aws_iam_openid_connect_provider.this.url}"
 }
}

data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}