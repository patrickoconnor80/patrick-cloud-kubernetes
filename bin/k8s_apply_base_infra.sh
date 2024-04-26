# Install Kustomize if not already installed in workspace
if ! ls | grep -q kustomize; then
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
fi

# Install Kustomize if not already installed in workspace
if ! istioctl version ; then
    curl -L https://istio.io/downloadIstio | sh -
    export PATH="$PATH:/var/lib/jenkins/workspace/kubernetes-terraform-dev/istio-1.21.2/bin"
fi

# Add helm repos
sh bin/helm_repo_add.sh

# Create storage class
kubectl apply -f manifests/storage/storage-class.yaml

# Install External Secrets so secrets from AWS Secrets Manager can be utilized
if ! helm list -n external-secrets | grep -q external-secrets; then
    helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
fi

# Update the volume ID's in the manifest
ALERT_MANAGER_PROMETHEUS_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-alert-manager-prometheus-pv | grep VolumeId | cut -d'"' -f 4)
PROMETHEUS_SERVER_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-prometheus-server-pv | grep VolumeId | cut -d'"' -f 4)
GRAFANA_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-grafana-pv | grep VolumeId | cut -d'"' -f 4)
sed -e "s/\vol-[0-9,A-Z]* #prometheus-alert-manager-tag/$ALERT_MANAGER_PROMETHEUS_PV #prometheus-alert-manager-tag/" \
    -e "s/\vol-[0-9,A-Z]* #prometheus-server-tag/$PROMETHEUS_SERVER_PV #prometheus-server-tag/" \
    -e "s/\vol-[0-9,A-Z]* #grafana-tag/$GRAFANA_PV #grafana-tag/" \
    manifests/monitoring/base/volumes.yaml | tee manifests/monitoring/base/volumes.yaml
cp manifests/monitoring/base/volumes_.yaml manifests/monitoring/base/volumes.yaml

# Apply Istio CRD's
istioctl apply -f manifests/istio/base/istio-crds.yaml

# Apply Argo CD CRD's
kubectl apply -f manifests/argo-cd/base/argo-cd-crds.yaml

# Apply Istio, Monitoring and ArgoCD
./kustomize build --enable-helm manifests/istio/base | kubectl apply -f -
./kustomize build --enable-helm manifests/monitoring/base | kubectl apply -f -
./kustomize build --enable-helm manifests/argo-cd/base | kubectl apply -f -

# Create Certs
export DOMAIN_NAME=patrick-cloud.com
export PREFIX=kubernetes
rm -rf certs
mkdir certs
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=$DOMAIN_NAME Inc./CN=$DOMAIN_NAME' -keyout certs/$DOMAIN_NAME.key -out certs/$DOMAIN_NAME.crt
openssl req -out certs/$PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout certs/$PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl req -out certs/$PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout certs/$PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl x509 -req -days 365 -CA certs/$DOMAIN_NAME.crt -CAkey certs/$DOMAIN_NAME.key -set_serial 0 -in certs/$PREFIX.$DOMAIN_NAME.csr -out certs/$PREFIX.$DOMAIN_NAME.crt

# Add TLS Secret for Istio Gateway
if ! kubectl get secrets -n istio-system | grep -q patrick-cloud-certs; then
    kubectl create secret tls patrick-cloud-certs -n istio-system --key certs/kubernetes.patrick-cloud.com.key --cert certs/kubernetes.patrick-cloud.com.crt
fi

# Store Nodeport Exposed by Istio Gateway in AWS Parameter Store so it can be referenced by the ALB
HTTPS_NODEPORT=$(kubectl describe svc -n istio-system istio-ingress | grep NodePort | grep https | grep -Eo '[0-9]{1,5}')
aws ssm put-parameter --name KUBERNETES_ISTIO_GATEWAY_HTTPS_NODEPORT --value $HTTPS_NODEPORT --type "String" --overwrite
STATUSPORT=$(kubectl describe svc -n istio-system istio-ingress | grep NodePort | grep status-port | grep -Eo '[0-9]{1,5}')
aws ssm put-parameter --name KUBERNETES_ISTIO_GATEWAY_STATUSPORT --value $STATUSPORT --type "String" --overwrite

# Istio Gateway Pod fails because the IstioD pod isn't up and running before it finishes. Delete to restart pod when IstioD is ready
kubectl delete pods --field-selector status.phase=Pending -n istio-system