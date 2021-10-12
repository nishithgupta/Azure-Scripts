#!/bin/bash

# Define variables. A detailed description of these variables in available in README.md file
RGName=
vNet=
vNetPf=
Subnet=
SubnetPf=
GWSubnetPf=
PipName=
VpnGW=
VpnGWType=
VpnGWVpntype=
VpnGWSku=
# VpnGWGen=Generation1/Generation2    use --vpn-gateway-generation for any SKU other than Basic and VpnGw1
LocalNWGW=
LocalNWGWPip=
LocalNWGWPf=
VPNCon=
SharedKey=

# Set Azure Subscription
SubscriptionId=$(az account show --query id --output tsv)
az account set --subscription $SubscriptionId

# Create vNet and Subnet
az network vnet create \
  --resource-group $RGName \
  --name $vNet \
  --address-prefix $vNetPf \
  --subnet-name $Subnet \
  --subnet-prefix $SubnetPf

# Create Gateway subnet. Name of the Gateway subnet will always be GatewaySubnet
az network vnet subnet create \
  --resource-group $RGName \
  --vnet-name $vNet \
  --address-prefix $GWSubnetPf \
  --name GatewaySubnet

# Create public IP for Virtual network gateway
az network public-ip create \
  --name $PipName \
  --resource-group $RGName \
  --allocation-method Dynamic

# Create Virtual Network Gateway of type VPN
az network vnet-gateway create \
  --resource-group $RGName \
  --name $VpnGW \
  --public-ip-address $PipName \
  --vnet $vNet \
  --gateway-type $VpnGWType \
  --vpn-type $VpnGWVpntype \
  --sku $VpnGWSku \
  --no-wait

# Create Local network gateway
az network local-gateway create \
  --gateway-ip-address $LocalNWGWPip \
  --name $LocalNWGW \
  --resource-group $RGName \
  --local-address-prefixes $LocalNWGWPf

# Create a logical VPN connection 
az network vpn-connection create \
  --name $VPNCon \
  --resource-group $RGName \
  --vnet-gateway1 $VpnGW \
  --location centralindia \
  --shared-key abc123 \
  --local-gateway2 $LocalNWGW
