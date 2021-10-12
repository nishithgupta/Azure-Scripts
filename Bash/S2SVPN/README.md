# Azure Site 2 Site VPN for Home Lab

![](https://github.com/nishithgupta/Azure-Scripts/blob/main/Bash/S2SVPN/site-to-site-diagram.png)

## Local Setup
For home lab ***local*** VPN setup, either use [pfsense](https://www.pfsense.org/download/), which is a free network firewall distribution, based on the FreeBSD operating system or a windows server with RRAS (Remoting and Routing Access service ) feature installed.

Following sources explain local as well as Azure side configuration using GUI. Go ahead and ready the local setup, then come back for scripted deployment of VPN Gateway, Local Network gateway and connection on Azure.

- Azure Site-to-Site VPN with PFSense - [scom27k](https://www.scom2k7.com/creating-a-site-to-site-azure-vpn-with-pfsense/)
- Creating a site-to-site Azure VPN with PFSense - [thetech133t](https://thetechl33t.com/2020/05/18/azure-site-to-site-vpn-with-pfsense/)
- Site-to-Site Azure VPN with a Windows RRAS Server - [Travis Roberts](https://www.youtube.com/watch?v=QQ40gxxxT8Y)
- Azure Site-To-Site (S2S) VPN With Windows Server 2019 - [Naglestad Consulting](https://blog.naglis.no/?p=3712)

## Azure Setup
For home lab ***Azure*** setup, use [homelab-create-s2s-vpn.sh](https://github.com/nishithgupta/Azure-Scripts/blob/main/Bash/S2SVPN/homelab-create-s2s-vpn.sh).
