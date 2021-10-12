# Azure Site-to-Site VPN for Home Lab
For Enterprise deployment for Site-to-Site VPN, follow Microsoft docuementation [here](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-cli).

![](https://guptanishith.com/wp-content/uploads/2021/10/site-to-site-diagram.png)

## Local Setup
For home lab ***local*** VPN setup, either use [pfsense](https://www.pfsense.org/download/), which is a free network firewall distribution, based on the FreeBSD operating system or a windows server with RRAS (Remoting and Routing Access service ) feature installed.

Following sources explain local as well as Azure side configuration using GUI. Go ahead and ready the local setup, then come back for scripted deployment of VPN Gateway, Local Network gateway and connection on Azure.

- Azure Site-to-Site VPN with PFSense - [scom27k](https://www.scom2k7.com/creating-a-site-to-site-azure-vpn-with-pfsense/)
- Creating a site-to-site Azure VPN with PFSense - [thetech133t](https://thetechl33t.com/2020/05/18/azure-site-to-site-vpn-with-pfsense/)
- Site-to-Site Azure VPN with a Windows RRAS Server - [Travis Roberts](https://www.youtube.com/watch?v=QQ40gxxxT8Y)
- Azure Site-To-Site (S2S) VPN With Windows Server 2019 - [Naglestad Consulting](https://blog.naglis.no/?p=3712)

## Azure Setup
For home lab ***Azure*** setup, use [homelab-create-s2s-vpn.sh](https://github.com/nishithgupta/Azure-Scripts/blob/main/Bash/S2SVPN/homelab-create-s2s-vpn.sh).

The script has multiple steps:
- Login to Azure
- Define Variables
- Create a Resource Group
- Create VNet and a Subnet
- Create a GatewaySubnet
- Create a Public IP
- Create Virtual Network Gateway
- Create Local Network Gateway
- Create a connection

Below is the description of some steps that require some explaination.

### _Login to Azure_
The scipt expects that the user who is going to execute it is already logged-in and has appropriate rights (RBAC).
If not, use `az login` to initiate the login process. If the CLI can open your default browser, it will do so and load an Azure sign-in page. Otherwise, open a browser page at [Device Login](https://aka.ms/devicelogin) and enter the authorization code displayed in your terminal.

Alternatively, use one of the below methods:
- Login by using username and password
```sh
az login -u <username> -p <password>
```
- Login by using username and password with avoid displaying the password
```sh
read -sp "Azure password: " AZ_PASS && echo && az login -u <username> -p $AZ_PASS
```
- Login by using service principal and password with avoid displaying the password
```sh
read -sp "Azure password: " AZ_PASS && echo && az login --service-principal -u <app-id> -p $AZ_PASS --tenant <tenant>
```
- Login by using service principal and certificate. This method involves creating a keyvault, generating a certificate and exporting it in pem format. Use [create-service-principal.sh](https://github.com/nishithgupta/Azure-Scripts/blob/main/Bash/Keyvault/create-service-principal.sh) for this purpose.
```sh
az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>
```
- Login with managed identity
```sh
az login --identity --username <client_id|object_id|resource_id>
```

### _Define Variables_

The script uses variables to be passed as a value to the parameters/switches. These variables need to be defined in advance (_at the begining of the script_) before script can be executed.

- **RGName -** The script expects that the Resource Group that will hold all VPN Gateway components has already been created. Define its name in `RGName` variable, for example `HubRG`. If not then use `az group create --name <resource group name> --location <location>` to create one and then define its name in the variable before executing the script.
- **vNet -** Define a name for the vNet before executing the script, for example `HubvNet`.
- **vNetPf -** Define vNet address space before executing the script, for example `172.16.0.0/16`. Make sure it doesn't overlap with on-premise (home) network.
- **Subnet -** Define a name for the subnet before executing the script, for example `HubSubnet`.
- **SubnetPf -** Define subnet address space before executing the script, for example `172.16.0.0/24`.
- **GWSubnetPf -** Define address space for GatewaySubnet. Smaller one should be enough for the lab, for example `172.16.1.0/28`.
- **PipName -** Define a name for the public ip to be used by Virtual network gateway, for example `Hub2OnPS2SVpnPip`.
- **VpnGW -** Define a name for Virtual network gateway, for example `HubvNNWGateway`.
- **VpnGWType -** Define type of Gateway. Possible values are Vpn, ExpressRoute and LocalGateway. For home lab purpose, use `Vpn`.
- **VpnGWVpntype -** Define type of VPN routing. Possible values are RouteBased and PolicyBased. `RouteBased` is default and suitable for home lab and many enterprise deployments. Not required if Gateway type if ExpressRoute. More info at [Azure Vpn Types](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#vpntype)
- **VpnGWSku -** Define a Vpn Gateway SKU. `Basic` or `VpnGw1` should be enough for home lab. More info at [Azure Gateway SKUs](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsku)
- **VpnGWGen -** Defining a generation is required if any SKU other than Basic and VpnGw1 is used. Possible values are `Generation1` and `Generation2`. Add `--vpn-gateway-generation Generation1/Generation2` in `az network vnet-gateway create` command in the script, depending on Gateway SKU choice.
- **LocalNWGW -** Define a name for Local Network Gateway, for example `OnPLocalNWGateway`. It represents on-premise(_home_) VPN.
- **LocalNWGWPip -** Define the public IP of home router/vpn device. Use [WhatismyIp](https://whatismyipaddress.com/) to determine the public IP. If you have a static public IP then use that. Everytime the public IP changes, simply go to Local Network Gateway that was created in Azure, under **Settings** click **Configuration**. Paste the new IP in **IP address** field and click **Save**.
![](https://guptanishith.com/wp-content/uploads/2021/10/Local-Network-gateway.png)
- **LocalNWGWPf -** Define address space of on-prem (_home_) network, for example `192.168.0.0/16`. Type `192.168.20.0/16 192.168.15.0/24` to define more than one address space. These are the internal IP address located on the on-premises (_home_) network and will be routed through VPN Gateway in Azure to VPN device (_pfsense or rras_) on-prem. If the IP address range changes or an additional address space is to be introduced then simply go to Local Network Gateway/Configuration, make the changes and click Save.
- **VPNCon -** Define a name for the logical connection, for example `Hub2OnPS2SVpnConnection`.
- **SharedKey -** Define a shared IPSecv2 key that was used during the VPN device configuration in on-prem (_home_).

## Final Comments
Wait for the deployment of VPN Gateway to finish. It may take 30 minutes or so. Once completed, go to the Local Network Gateway that was created, under **Settings** click **Connections**. The status should show **Connected**. Depending on vpn setup (_pfsense or rras_) in home lab, you may have to trigger the connection manually.
