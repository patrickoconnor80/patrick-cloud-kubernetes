if ! helm repo list | grep -q external-secrets; then
    helm repo add external-secrets https://charts.external-secrets.io
fi
if ! helm repo list | grep -q istio; then
    helm repo add istio https://istio-release.storage.googleapis.com/charts
fi
if ! helm repo list | grep -q prometheus-community; then
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi
if ! helm repo list | grep -q grafana; then
    helm repo add grafana https://grafana.github.io/helm-charts
fi
if ! helm repo list | grep -q argo; then
    helm repo add argo https://argoproj.github.io/argo-helm
fi
if ! helm repo list | grep -q kuberay; then
    helm repo add kuberay https://ray-project.github.io/kuberay-helm/
fi