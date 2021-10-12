# Define variables
RGName=HubRG                # Name of the Resource group to be created
KVName=KVforAuth            # A globally unique name of the Keyvault to be created
CertName=CertforLoginAuth   # Name of the Certificate to be created inside Keyvault
SecretName=$CertName        # Secret Name is always same as Certificate name
SPName=SPforLoginAuth       # name of Service principal

# Set Azure Subscription
SubscriptionId=$(az account show --query id --output tsv)
az account set --subscription $SubscriptionId

# Creat Azure Resource Group. Save resource id into a variable.
RGResourceId=$(az group create --name $RGName --location centralindia --query id --output tsv)
# az config set defaults.group=$RGName

# Register the Key Vault resource provider. Create Key Vault that uses Azure RBAC model. Save Keyvault resource id into a variable
az provider register -n Microsoft.KeyVault
KVId=$(az keyvault create --name $KVName --location centralindia --resource-group $RGName --enable-rbac-authorization true --query id --output tsv)

# Assign a role to the user who created the Keyvault. The role should have enough permission to be able to create a service principal by generating a self-signed certificate in the Keyvault.
ObjectID=$(az ad signed-in-user show --query objectId -o tsv)
az role assignment create --role "Key Vault Administrator" --assignee-object-id $ObjectID --assignee-principal-type User --scope $KVId

# Create service principal by generating a self-signed certificate in Keyvault. Assign Contributor role to the service principal on Resource Group. Save appId into a variable.
# Not using --skip-assignment here, If it is used then --scopes is ignored. By default SP creation assigns Contributor role to the service principal on the subscription.
# --skip-assignment forces no default assignment. --scope and --role allow manually assigning a role to a scope.
# To remove assignment of a user, group or service principal over a scope, use az role assignment delete --assignee <APP_ID> --role Contributor --scopes /.../..
SPAppId=$(az ad sp create-for-rbac --name $SPName --role Contributor --scopes $RGResourceId --create-cert --cert $CertName --keyvault $KVName --query appId --output tsv)

# Save tenantId into a variable
SPTenantId=$(az ad sp show --id $SPAppId --query appOwnerTenantId --output tsv)

##################### Alternatives to az ad sp show ##########################################
# az ad sp list --display-name SPforLoginAuth --query [].[appId,appOwnerTenantId]            #
# or                                                                                         #
# az ad sp list --display-name SPforLoginAuth --query "[].{id:appId,tenant:appOwnerTenantId}"#
##############################################################################################

# Save secret id into a variable.Download the certificate with its private key in pfx format and then convert it to pem format. Secret Name is equal to Certificate name.
KVSecretId=$(az keyvault secret show --name $SecretName --vault-name $KVName --query id --output tsv)
az keyvault secret download --id $KVSecretId --file certificate.pfx --encoding base64
openssl pkcs12 -in certificate.pfx -passin pass: -out certificate.pem -nodes

# Save the downloaded pem file somewhere safe.
download certificate.pem

# Login to Azure from Service principal using certificate authentication
az login --service-principal --username $SPAppId --tenant $SPTenantId --password certificate.pem

# Define variables
vNet=HubvNet                            # Name of the vNet
vNetPf=172.16.0.0/16                    # vNet address space
Subnet=HubSubnet                        # Name of the Subnet
SubnetPf=172.16.0.0/24                  # Subnet address space
GWSubnetPf=172.16.1.0/24                # Address space for Gateway subnet
PipName=Hub2OnPS2SVpnPip                # Name of the public ip to be used by Virtual network gateway
VpnGW=HubvNNWGateway                    # Name of the VPN Gateway
VpnGWType=Vpn                           # Type of Gateway. Other possible values are  ExpressRoute and LocalGateway
VpnGWVpntype=RouteBased                 # Type of VPN routing. Other possible value is PolicyBased. RouteBased is default. Not required if Gateway type if ExpressRoute.
VpnGWSku=Basic                          # See https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsku and https://docs.microsoft.com/en-us/cli/azure/network/vnet-gateway?view=azure-cli-latest#az_network_vnet_gateway_create
# VpnGWGen=Generation1/Generation2      use --vpn-gateway-generation for any SKU other than Basic and VpnGw1
LocalNWGW=HubLocalNWGateway             # Name of the local (on-prem) network gateway
LocalNWGWPip=122.177.75.17              # Public IP address of on-prem router/vpn device.
LocalNWGWPf=192.168.0.0/16              # Address space of the local (on-prem) network.
VPNCon=Hub2OnPS2SVpnConnection          # Name of the VPN connection
SharedKey=ADGJLPIYRWZCBM135792468       # A Shared IPsecv2 key. This will be needed on on-premise vpn device also.

# Create vNet and Subnet
az network vnet create --resource-group $RGName --name $vNet --address-prefix $vNetPf --subnet-name $Subnet --subnet-prefix $SubnetPf

# Create Gateway subnet. Name of the Gateway subnet will always be GatewaySubnet
az network vnet subnet create --resource-group $RGName --vnet-name $vNet --address-prefix $GWSubnetPf --name GatewaySubnet

# Create public IP for Virtual network gateway
az network public-ip create --name $PipName --resource-group $RGName --allocation-method Dynamic

# Create Virtual Network Gateway of type VPN
az network vnet-gateway create --resource-group $RGName --name $VpnGW --public-ip-address $PipName --vnet $vNet --gateway-type $VpnGWType --vpn-type $VpnGWVpntype --sku $VpnGWSku --no-wait

# Create Local network gateway
az network local-gateway create --gateway-ip-address $LocalNWGWPip --name $LocalNWGW --resource-group $RGName --local-address-prefixes $LocalNWGWPf

# Create a logical VPN connection 
az network vpn-connection create --name $VPNCon --resource-group $RGName --vnet-gateway1 $VpnGW --location centralindia --shared-key abc123 --local-gateway2 $LocalNWGW
