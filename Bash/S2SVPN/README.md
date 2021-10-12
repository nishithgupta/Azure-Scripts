# Azure Site 2 Site VPN for Home Lab

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
- Create a Resource Group
- Create VNet and a Subnet
- Create a GatewaySubnet
- Create a Public IP
- Create Virtual Network Gateway
- Create Local Network Gateway
- Create a connection

Below is the description of some steps that require some explaination.

#### _Login to Azure_
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
