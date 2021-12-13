subscription = b10f1bdc-6edd-4a40-9930-25bd7c187adc
resource = team3ResourceGroup
cluster = team3AKSCluster
team = youscanTeam3
template = team3chart
release = team3chart

set-subscription:
	az account set --subscription $(subscription)

create-resource-group:
	az group create --name $(resource) --location westeurope

crete-acr:
	az acr create --resource-group $(resource) --name $(team) --sku Basic

create-aks:
	az aks create --resource-group $(resource) --name $(cluster) --node-count 1 --enable-addons monitoring --generate-ssh-keys

enable-managed-identity:
	az aks update -g $(resource) -n $(cluster) --enable-managed-identity

account-list:
	az account list -o table

enable-autocaling:
	az aks update \
	--resource-group $(resource) \
	--name $(cluster) \
	--enable-cluster-autoscaler \
	--min-count 1 \
	--max-count 3

attach-acr:
	az aks update -n $(cluster) -g $(resource) --attach-acr $(team)


install-deps:
	brew install kubectx
	brew install k9s

get-credentials:
	az aks get-credentials --resource-group $(resource) --name $(cluster)

get-nodes:
	kubectl get nodes

add-node-pool:
	az aks nodepool add \
--resource-group $(resource) \
--cluster-name $(cluster) \
--name userpool \
--node-count 1 \
--mode User


install-nginx:
	az acr import -n $(team) --source docker.io/library/nginx:latest --image nginx:v1

helm-update:
	helm upgrade $(release) $(template)

get-nginx:
	NAMESPACE=ingress-basic
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
    
deploy-nginx:
	helm install nginx-ingress ingress-nginx/ingress-nginx \
    --create-namespace --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

get-podes:
	kubectl get pods --all-namespaces

get-services:
	kubectl get services --all-namespaces

ingress-logs:
	kubectl get ing -n ingress-basic

ingress-get-pods:
	kubens ingress-basic
	kubectl get pods

nginx-logs:
	kubectl logs nginx-ingress-ingress-nginx-controller-588dcd5598-swf69

disable-readyz:
	curl -d "" http://3team.20.56.200.122.nip.io/readyz/disable

kill-pod:
	kubectl delete pods team3chart-7686bc74b4-dcrfk

enable-nodepool-autoscaling:
	az aks nodepool update --cluster-name $(cluster) \
    --name userpool \
	--resource-group $(resource) \
	--enable-cluster-autoscaler \
	--min-count 1 \
	--max-count 10