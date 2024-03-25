# Create namespaces
kubectl apply -f ../cfg/namespaces.yaml

# Install External Secrets so secrets from AWS Secrets Manager can be utilized
if ! helm repo list | grep -q external-secrets; then
    helm repo add external-secrets https://charts.external-secrets.io
fi
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
# Create External Secrets
kubectl apply -f ../cfg/external_secrets.yaml

# Create Persistent Volumes so they can be re-used after destorying the EKS Cluster(Money saver)
ALERT_MANAGER_PROMETHEUS_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-alert-manager-prometheus-pv | grep VolumeId | cut -d'"' -f 4)
PROMETHEUS_SERVER_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-prometheus-server-pv | grep VolumeId | cut -d'"' -f 4)
sed "s/\$PROMETHEUS_SERVER_PV/$PROMETHEUS_SERVER_PV/" ../cfg/prometheus_server_pv.yaml  | kubectl apply -f -
sed "s/\$ALERT_MANAGER_PROMETHEUS_PV/$ALERT_MANAGER_PROMETHEUS_PV/" ../cfg/prometheus_alert_manager_pv.yaml | kubectl apply -f -

# Create storage class
kubectl apply -f ../cfg/storage_class.yaml

# Install Istio so the proxy-sidecar can be injected into the rest of the pods
if ! helm repo list | grep -q istio; then
    helm repo add istio https://istio-release.storage.googleapis.com/charts
fi
helm repo update istio
helm install istio-base istio/base --namespace istio-system
helm install istiod istio/istiod --namespace istio-system --set meshConfig.accessLogFile=/dev/stdout --wait 
# Set to  NodePort instaed of Load Balancer as an ALB will be created(Istio can't create ALB, only ELB/NLB)
helm install istio-ingress istio/gateway --namespace istio-ingress --set defaults.service.type=NodePort --wait

# Install Prometheus
if ! helm repo list | grep -q prometheus-community; then
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi
helm repo update prometheus-community
helm install prometheus prometheus-community/prometheus --namespace monitoring --values ../helm_values/prometheus_values.yaml

# Install Grafana
GRAFANA_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-grafana-pv | grep VolumeId | cut -d'"' -f 4)
sed "s/\$GRAFANA_PV/$GRAFANA_PV/" ../cfg/grafana_pv.yaml | kubectl apply -f -
if ! helm repo list | grep -q grafana; then
    helm repo add grafana https://grafana.github.io/helm-charts
fi
helm repo update grafana
helm install grafana grafana/grafana --namespace monitoring --values ../helm_values/grafana_values.yaml

# Install Istio add-ons
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done

# Set up Gateway last as it references a lot of the pods
kubectl apply -f ../cfg/istio_dashboards_gateway.yaml


# Install ArgoCD
if ! helm repo list | grep -q argocd; then
    helm repo add argo https://argoproj.github.io/argo-helm
fi
helm install argo-cd argo/argo-cd --version 6.7.3 --namespace argocd --values ../helm_values/argocd_values.yaml

if ! helm repo list | grep -q aws-load-balancer-controller; then
    helm repo add eks https://aws.github.io/eks-charts
fi
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --values ../helm_values/aws_lb_controller_values.yaml

#kubectl create -n istio-system secret generic tls-secret --from-file=key=../certs/key.pem --from-file=cert=../certs/cert.pem

kubectl create -n istio-system secret tls patrick-cloud-credential \
  --key=../certs/kubernetes.patrick-cloud.com.key \
  --cert=../certs/kubernetes.patrick-cloud.com.crt
kubectl create -n istio-ingress secret tls patrick-cloud-credential \
  --key=../certs/kubernetes.patrick-cloud.com.key \
  --cert=../certs/kubernetes.patrick-cloud.com.crt

kubectl apply -f ../cfg/aws_lb_controller.yaml
kubectl apply -f ../cfg/2048.yaml