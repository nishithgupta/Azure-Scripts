#!/bin/bash

# Define variables. A detailed description of these variables in available in README.md file
VMName=MyVM1
VMLocation=centralindia
VMImage=win2019datacenter OR MicrosoftWindowsServer:WindowsServer:2019-datacenter-gensecond:latest
VMSize=Standard_B2s
VMOSDiskType=Premium_LRS or StandardSSD_LRS or Standard_LRS or UltraSSD_LRS or Premium_ZRS or StandardSSD_ZRS
VMOSDiskName=MyVM01-OSDisk
VMOSDiskSize=200
DataDisk1Size=10
DataDisk2Size=20
AdminUser=AzAdmin
AdminPassword=P@$$w0r6@123
RGName=MyResourceGroup
vNet=MyvNet
Subnet=MySubnet
PipName=MyVM1-pip
PipSKU=Basic or Standard
NSGName=MyVM1-NSG
NicName=MyVM1-NIC

# Create a public IP address.
az network public-ip create --resource-group $RGName --name $PipName --sku $PipSKU --allocation-method Static

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
    --resource-group $RGName \
    --name $VMName \
    --location $VMLocation \
    --nics $NicName \
    --image $VMImage \
    --size $VMSize \
    --os-disk-name $VMOSDiskName \
    --os-disk-size-gb $VMOSDiskSize \
    --storage-sku $VMOSDiskType \
    --data-disk-sizes-gb $DataDisk1Size $DataDisk2Size \
    --admin-username $AdminUser \
    --admin-password $AdminPassword
    --enable-auto-update

# Open port 3389 to allow RDP traffic to host.
az vm open-port --port 3389 --resource-group $RGName --name $VMName

# End of Script
