# Install External Secrets so secrets from AWS Secrets Manager can be utilized
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

# Create Persistent Volumes so they can be re-used after destorying the EKS Cluster(Money saver)
ALERT_MANAGER_PROMETHEUS_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-alert-manager-prometheus-pv | grep VolumeId | cut -d'"' -f 4)
PROMETHEUS_SERVER_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-prometheus-server-pv | grep VolumeId | cut -d'"' -f 4)
GRAFANA_PV=$(aws ec2 describe-volumes --filters Name=tag:Name,Values=patrick-cloud-eks-grafana-pv | grep VolumeId | cut -d'"' -f 4)
sed "s/\$GRAFANA_PV/$GRAFANA_PV/" ../temp_cfg/grafana_pv.yaml | kubectl apply -f -
sed "s/\$PROMETHEUS_SERVER_PV/$PROMETHEUS_SERVER_PV/" ../temp_cfg/prometheus_server_pv.yaml  | kubectl apply -f -
sed "s/\$ALERT_MANAGER_PROMETHEUS_PV/$ALERT_MANAGER_PROMETHEUS_PV/" ../temp_cfg/prometheus_alert_manager_pv.yaml | kubectl apply -f -

# Create namespaces, storage class and external secrets
kubectl apply -f ../temp_cfg/namespaces.yaml
kubectl apply -f ../temp_cfg/storage_class.yaml
kubectl apply -f ../temp_cfg/external_secrets.yaml

# Install Istio so the proxy-sidecar can be injected into the rest of the pods
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base --namespace istio-system
helm install istiod istio/istiod --namespace istio-system --set meshConfig.accessLogFile=/dev/stdout --wait 
helm install istio-ingress istio/gateway --namespace istio-ingress --wait

# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace monitoring --values ../cfg/prometheus_values.yaml

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana --namespace monitoring --values ../cfg/grafana_values.yaml

# Install Istio add-ons
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done

# Set up Gateway last as it references a lot of the pods
kubectl apply -f ../temp_cfg/istio_dashboards_gateway.yaml