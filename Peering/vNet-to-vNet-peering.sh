#!/bin/bash

# Variables for Hub to Spoke vNet Peering
PeeringName1=HubvNet2CtxInfravNet
vNetName1=HubvNet
RGName1=HubRG
# Since Spoke vNet (remote) is in a different resource group then Hub vNet, Resource ID of the vNet should be used than its name.
RemotevNetID1=/subscriptions/e581e838-9155-4c3b-99a9-c0515258df10/resourceGroups/CtxInfraRG/providers/Microsoft.Network/virtualNetworks/CtxInfravNet

# Variables for Spoke to Hub vNet peering
PeeringName2=CtxInfravNet2HubvNet
vNetName2=CtxInfravNet
RGName2=CtxInfraRG
# Since Hub (remote) vNet is in a different resource group then Spoke vNet, Resource ID of the vNet should be used than its name.
RemotevNetID2=/subscriptions/e581e838-9155-4c3b-99a9-c0515258df10/resourceGroups/HubRG/providers/Microsoft.Network/virtualNetworks/HubvNet

# Create peering from Hub to Spoke
az network vnet peering create \
--resource-group $RGName1 \
--name $PeeringName1 \
--vnet-name $vNetName1 \
--remote-vnet $RemotevNetID1 \
--allow-vnet-access \
--allow-gateway-transit \
--allow-forwarded-traffic

# Create peering from Spoke to Hub
az network vnet peering create \
--resource-group $RGName2 \
--name $PeeringName2 \
--vnet-name $vNetName2 \
--remote-vnet $RemotevNetID2 \
--allow-vnet-access \
--use-remote-gateways
