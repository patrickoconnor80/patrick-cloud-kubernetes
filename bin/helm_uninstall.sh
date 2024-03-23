helm list -A

for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl delete -f $ADDON_URL
done

kubectl delete -f ../temp_cfg/istio_dashboards_gateway.yaml

helm uninstall grafana -n monitoring
helm uninstall prometheus -n monitoring
helm uninstall istio-ingress -n istio-ingress
helm uninstall istio-base -n istio-system
helm uninstall istiod -n istio-system

kubectl delete -f ../temp_cfg/namespaces.yaml
kubectl delete -f ../temp_cfg/storage_class.yaml