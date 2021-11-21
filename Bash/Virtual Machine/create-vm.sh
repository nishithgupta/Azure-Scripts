#!/bin/bash

# Update for your admin password
VMName=AZDDC01
VMLocation=
VMImage=
VMSize=
VMOSDiskType=
AdminUser=CZAdmin
AdminPassword=Divergent@123
RGName=CtxInfraRG
vNet=CtxInfravNet
Subnet=CtxInfraSubnet
PipName=AZDDC01-pip
NSGName=AZDDC01-NSG
NicName=AZDDC01-NIC

# Create a public IP address.
az network public-ip create --resource-group $RGName --name $PipName

# Create a network security group.
az network nsg create --resource-group $RGName --name $NSGName

# Create a virtual network card and associate it with public IP address and NSG.
az network nic create \
  --resource-group $RGName \
  --name $NicName \
  --vnet-name $vNet \
  --subnet $Subnet \
  --network-security-group $NSGName \
  --public-ip-address $PipName

# Create a virtual machine. 
az vm create \
    --resource-group myResourceGroup \
    --name $VMName \
    --location westeurope \
    --nics $NicName \
    --image win2016datacenter \
    --admin-username $AdminUser \
    --admin-password $AdminPassword

# Open port 3389 to allow RDP traffic to host.
az vm open-port --port 3389 --resource-group $RGName --name $VMName
