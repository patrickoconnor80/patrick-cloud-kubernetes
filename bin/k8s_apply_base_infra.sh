# Add helm repos
ls
sh bin/helm_repo_add.sh

# Create storage class
kubectl apply -f manifests/storage/storage-class.yaml

# Install External Secrets so secrets from AWS Secrets Manager can be utilized
if ! helm list | grep -q external-secrets; then
    helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
fi

# Update the volume ID's in the manifest
ALERT_MANAGER_PROMETHEUS_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-alert-manager-prometheus-pv | grep VolumeId | cut -d'"' -f 4)
PROMETHEUS_SERVER_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-prometheus-server-pv | grep VolumeId | cut -d'"' -f 4)
GRAFANA_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-grafana-pv | grep VolumeId | cut -d'"' -f 4)
sed -e "s/\vol-[0-9,A-Z]* #prometheus-alert-manager-tag/$ALERT_MANAGER_PROMETHEUS_PV #prometheus-alert-manager-tag/" \
    -e "s/\vol-[0-9,A-Z]* #prometheus-server-tag/$PROMETHEUS_SERVER_PV #prometheus-server-tag/" \
    -e "s/\vol-[0-9,A-Z]* #grafana-tag/$GRAFANA_PV #grafana-tag/" \
    manifests/monitoring/base/volumes.yaml  | kubectl apply -f -

# Apply Istio, Monitoring and ArgoCD
./kustomize build --enable-helm manifests/istio/base | kubectl apply -f -
./kustomize build --enable-helm manifests/monitoring/base | kubectl apply -f -
./kustomize build --enable-helm manifests/argocd/base | kubectl apply -f -

# Add TLS Secret for Istio Gateway
if ! kubectl get secrets -n istio-system | grep -q patrick-cloud-certs; then
    kubectl create secret tls patrick-cloud-certs -n istio-system --key certs/kubernetes.patrick-cloud.com.key --cert certs/kubernetes.patrick-cloud.com.crt
fi

# Store Nodeport Exposed by Istio Gateway in AWS Parameter Store so it can be referenced by the ALB
HTTPS_NODEPORT=$(kubectl describe svc -n istio-system istio-ingress | grep NodePort | grep https | grep -Eo '[0-9]{1,5}')
aws ssm put-parameter --name KUBERNETES_ISTIO_GATEWAY_HTTPS_NODEPORT --value $HTTPS_NODEPORT --type "String" --overwrite
STATUSPORT=$(kubectl describe svc -n istio-system istio-ingress | grep NodePort | grep status-port | grep -Eo '[0-9]{1,5}')
aws ssm put-parameter --name KUBERNETES_ISTIO_GATEWAY_STATUSPORT --value $STATUSPORT --type "String" --overwrite