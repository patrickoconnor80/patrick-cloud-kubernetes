helm upgrade -f ../helm_values/grafana_values.yaml -n monitoring grafana grafana/grafana
helm upgrade -f ../helm_values/prometheus_values.yaml -n monitoring prometheus prometheus-community/prometheus
helm upgrade -n istio-ingress istio-ingress istio/gateway --set defaults.service.type=NodePort
helm upgrade -f ../helm_values/argocd_values.yaml -n argocd argo-cd argo/argo-cd