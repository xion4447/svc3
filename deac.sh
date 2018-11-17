#!/bin/bash

az vm deallocate -g myResourceGroup -n svc1-vm1
az vm delete -g myResourceGroup -n svc1-vm1


az vm deallocate -g myResourceGroup -n  myVm
az vm delete -g myResourceGroup -n  myVm

az network nic delete -g myResourceGroup -n myNIC
 az network vnet delete -g myResourceGroup -n myVnet

# delete storage
