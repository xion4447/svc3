#!/bin/bash

#az vm deallocate -g myResourceGroup -n svc1-vm1
#az vm delete -g myResourceGroup -n svc1-vm1

echo "removing tfstate cookies"
rm terraform.tfstate*

echo "deallocating VM"
az vm deallocate -g myResourceGroup -n  myVm
echo "deleting resource group"
az vm delete -g myResourceGroup -n  myVm --yes
echo "deleting nic"
az network nic delete -g myResourceGroup -n myNIC 
echo "deleting vnet"
az network vnet delete -g myResourceGroup -n myVnet
echo "deleting disk"
az disk delete -g myResourceGroup -n myOsDisk  --yes

# delete storage
