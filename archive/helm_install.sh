# Add all Helm Repos
sh ./helm_repo_add.sh

# Create storage class
kubectl apply -f manifests/storage/storage_class.yaml

# Install External Secrets so secrets from AWS Secrets Manager can be utilized
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

# Install Istio so the proxy-sidecar can be injected into the rest of the pods
kubectl -f apply manifests/istio/namespace.yaml
helm repo update istio
helm install istio-base istio/base --namespace istio-system
helm install istiod istio/istiod --namespace istio-system --set meshConfig.accessLogFile=/dev/stdout --wait 
# Set to  NodePort instaed of Load Balancer as an ALB will be created(Istio can't create ALB, only ELB/NLB)
helm install istio-ingress istio/gateway --namespace istio-system --set defaults.service.type=NodePort --wait
# Create secret for self-signed certs
kubectl create secret tls patrick-cloud-certs -n istio-system --key certs/kubernetes.patrick-cloud.com.key --cert certs/kubernetes.patrick-cloud.com.crt
# Install Istio add-ons
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done
# Apply Gateway, Peer Authenication and Kiali Virtual Service 
kubectl apply -f manifests/istio

# Create Persistent Volumes so they can be re-used after destorying the EKS Cluster
ALERT_MANAGER_PROMETHEUS_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-alert-manager-prometheus-pv | grep VolumeId | cut -d'"' -f 4)
PROMETHEUS_SERVER_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-prometheus-server-pv | grep VolumeId | cut -d'"' -f 4)
GRAFANA_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-grafana-pv | grep VolumeId | cut -d'"' -f 4)
sed "s/\$PROMETHEUS_SERVER_PV/$PROMETHEUS_SERVER_PV/" manifests/monitoring/prometheus_server_pv.yaml  | kubectl apply -f -
sed "s/\$ALERT_MANAGER_PROMETHEUS_PV/$ALERT_MANAGER_PROMETHEUS_PV/" ../cfg/prometheus_alert_manager_pv.yaml | kubectl apply -f -
sed "s/\$GRAFANA_PV/$GRAFANA_PV/" ../cfg/grafana_pv.yaml | kubectl apply -f -

# Install Prometheus
kubectl -f apply manifests/monitoring/namespace.yaml
helm repo update prometheus-community
helm install prometheus prometheus-community/prometheus --namespace monitoring --values manifests/monitoring/helm_prometheus_values.yaml

# Install Grafana
helm repo update grafana
helm install grafana grafana/grafana --namespace monitoring --values manifests/monitoring/helm_grafana_values.yaml

# Apply Grafana Credentials External Secrets and Istio Virtual Services
kubectl apply -f manifests/monitoring

# Install Argo CD
kubectl -f apply manifests/argocd/namespace.yaml
helm install argo-cd argo/argo-cd --version 6.7.3 --namespace argocd --values ../helm_values/argocd_values.yaml
# Apply Argo CD Projects, Applications and Istio Virtual Service
kubectl apply -f manifests/argocd

# Store Nodeport Exposed by Istio Gateway in AWS Parameter Store so it can be referenced by the ALB
HTTPS_NODEPORT=$(kubectl describe svc -n istio-system istio-ingress | grep NodePort | grep https | grep -Eo '[0-9]{1,5}')
aws ssm put-parameter --name KUBERNETES_ISTIO_GATEWAY_HTTPS_NODEPORT --value $HTTPS_NODEPORT --type "String" --overwrite
STATUSPORT=$(kubectl describe svc -n istio-system istio-ingress | grep NodePort | grep status-port | grep -Eo '[0-9]{1,5}')
aws ssm put-parameter --name KUBERNETES_ISTIO_GATEWAY_STATUSPORT --value $STATUSPORT --type "String" --overwrite

if ! helm repo list | grep -q aws-load-balancer-controller; then
    helm repo add eks https://aws.github.io/eks-charts
fi

# Install AWS ALB Controller
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --values ../helm_values/aws_lb_controller_values.yaml

# kubectl apply -f ../cfg/aws_lb_controller.yaml
