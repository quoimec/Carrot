#!/bin/bash

AZURE_SUBSCRIPTION="2f4eaba0-24c4-44ed-b4ff-27715a3aec0d"
AZURE_LOCATION="australiaeast"

AZURE_GROUP="carrot-dev"
AZURE_KUBE="carrot-kube"
AZURE_STATIC="carrot-static" 

# Set Default Values
az configure --defaults location=$AZURE_LOCATION subscription=$AZURE_SUBSCRIPTION output=none

# Create Resource Group
az group create \
    --name $AZURE_GROUP \

# Create Kubernetes Cluster        
# az aks create \
#     --resource-group $AZURE_GROUP \
#     --name $AZURE_KUBE \
#     --dns-name-prefix "$AZURE_KUBE-dns"\
#     --node-count 2 \
#     --enable-addons monitoring,virtual-node,http_application_routing \
#     --generate-ssh-keys
    
AZURE_KUBEGROUP=$(az aks show --resource-group $AZURE_GROUP --name $AZURE_KUBE --query nodeResourceGroup --output tsv)

az configure --defaults group=$AZURE_KUBEGROUP

# Create Static Volume
az disk create \
  --name $AZURE_DISK \
  --size-gb 64 \
  --sku StandardSSD_LRS

# Create Static IP
az network public-ip create \
    --name $AZURE_STATIC \
    --allocation-method static

AZURE_DISK_ID=$(az disk show --name $AZURE_DISK --query id --output tsv)
AZURE_STATIC_IP=$(az network public-ip show --resource-group $AZURE_KUBEGROUP --name $AZURE_STATIC --query ipAddress --output tsv)

echo ""
echo "Azure Static IP: $AZURE_STATIC_IP"
echo ""
echo "Azure Disk ID: $AZURE_DISK_ID"




