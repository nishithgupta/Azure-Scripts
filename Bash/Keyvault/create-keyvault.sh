#!/bin/bash

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

# Save secret id into a variable.Download the certificate with its private key in pfx format and then convert it to pem format. Secret Name is equal to Certificate name.
KVSecretId=$(az keyvault secret show --name $SecretName --vault-name $KVName --query id --output tsv)
az keyvault secret download --id $KVSecretId --file certificate.pfx --encoding base64
openssl pkcs12 -in certificate.pfx -passin pass: -out certificate.pem -nodes

# Save the downloaded pem file somewhere safe.
download certificate.pem

# Login to Azure from Service principal using certificate authentication
az login --service-principal --username $SPAppId --tenant $SPTenantId --password certificate.pem
