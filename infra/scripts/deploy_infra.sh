#!/bin/bash

###################
### Infra Setup ###
###################

### Parameters
program="ugur"
locationLong="westeurope"
locationShort="euw"
project="kafka"
stageLong="dev"
stageShort="d"
instance="001"

kubernetesVersion="1.23.5"

### Variables
resourceGroupName="rg-$program-$locationShort-$project-$stageShort-$instance"
aksName="aks-$program-$locationShort-$project-$stageShort-$instance"

### Resource Group
echo "Checking resource group [$resourceGroupName] ..."

resourceGroup=$(az group show \
    --name $resourceGroupName \
    2> /dev/null \
    | jq)

if [[ $resourceGroup == "" ]]; then    
    echo " -> Resource group does not exist. Creating ..."

    resourceGroup=$(az group create \
        --name $resourceGroupName \
        --location $locationLong \
        2> /dev/null \
        | jq) 

    echo -e " -> Resource group is created successfully.\n"
else
    echo -e " -> Resource group already exists.\n"
fi

### AKS
echo "Checking AKS [$aksName] ..."

aks=$(az aks show \
    --resource-group $resourceGroupName \
    --name $aksName \
    2> /dev/null \
    | jq)

if [[ $aks == "" ]]; then    
    echo " -> AKS does not exist. Creating ..."

    aks=$(az aks create \
        --resource-group $resourceGroupName \
        --name $aksName \
        --location $locationLong \
        --kubernetes-version $kubernetesVersion \
        --node-count 1 \
        --generate-ssh-keys \
        2> /dev/null \
        | jq)

    echo -e " -> AKS is created successfully.\n"
else
    echo -e " -> AKS already exists.\n"
fi

# AKS credentials
az aks get-credentials \
    --resource-group $resourceGroupName \
    --name $aksName \
    --overwrite-existing
