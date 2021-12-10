set-subscription:
	az account set --subscription b10f1bdc-6edd-4a40-9930-25bd7c187adc

create-resource-group:
	az group create --name team3ResourceGroup --location westeurope

crete-acr:
	az acr create --resource-group team3ResourceGroup --name youscanTeam3 --sku Basic

create-aks:
	az aks create --resource-group team3ResourceGroup --name team3AKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys

enable-managed-identity:
	az aks update -g team3ResourceGroup -n team3AKSCluster --enable-managed-identity

account-list:
	az account list -o table

enable-autocaling:
	az aks update \
	--resource-group team3ResourceGroup \
	--name team3AKSCluster \
	--enable-cluster-autoscaler \
	--min-count 1 \
	--max-count 3

attach-acr:
	az aks update -n team3AKSCluster -g team3ResourceGroup --attach-acr youscanTeam3