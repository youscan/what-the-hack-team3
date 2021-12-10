subscription = b10f1bdc-6edd-4a40-9930-25bd7c187adc
resource = team3ResourceGroup
culster = team3AKSCluster

set-subscription:
	az account set --subscription $(subscription)

create-resource-group:
	az group create --name $(resource) --location westeurope

crete-acr:
	az acr create --resource-group $(resource) --name youscanTeam3 --sku Basic

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
	az aks update -n $(cluster) -g $(resource) --attach-acr youscanTeam3