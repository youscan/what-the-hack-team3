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