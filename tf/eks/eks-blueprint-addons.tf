module "eks_blueprints_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons?ref=08650fd2b4bc894bde7b51313a8dc9598d82e925"

  cluster_name      = local.cluster_name
  cluster_endpoint  = aws_eks_cluster.this.endpoint
  cluster_version   = aws_eks_cluster.this.version
  oidc_provider     = substr(aws_eks_cluster.this.identity.0.oidc.0.issuer, -32, -1)
  oidc_provider_arn = aws_iam_openid_connect_provider.this.arn

  enable_cloudwatch_metrics = true

  enable_aws_for_fluentbit = true
  aws_for_fluentbit_helm_config = {
    aws_for_fluent_bit_cw_log_group           = "/${local.cluster_name}/worker-fluentbit-logs"
    aws_for_fluentbit_cwlog_retention_in_days = 7 #days
    values = [
      yamlencode({
        name              = "kubernetes"
        match             = "kube.*"
        kubeURL           = "https://kubernetes.default.svc.cluster.local:443"
        mergeLog          = "On"
        mergeLogKey       = "log_processed"
        keepLog           = "On"
        k8sLoggingParser  = "On"
        k8sLoggingExclude = "Off"
        bufferSize        = "0"
        hostNetwork       = "true"
        dnsPolicy         = "ClusterFirstWithHostNet"
        filter = {
          extraFilters = <<-EOT
            Kube_Tag_Prefix     application.var.log.containers.
            Labels              Off
            Annotations         Off
            Use_Kubelet         true
            Kubelet_Port        10250
            Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
          EOT
        }
        cloudWatch = {
          enabled         = "true"
          match           = "*"
          region          = data.aws_region.current
          logGroupName    = "/${local.prefix}/worker-fluentbit-logs"
          logStreamPrefix = "fluentbit-"
          autoCreateGroup = "true"
        }
      })
    ]
  }

#   enable_karpenter = true
#   karpenter_helm_config = {
#     repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#     repository_password = data.aws_ecrpublic_authorization_token.token.password
#   }
#   karpenter_node_iam_instance_profile        = module.karpenter.instance_profile_name
#   karpenter_enable_spot_termination_handling = true

  tags = local.tags
}