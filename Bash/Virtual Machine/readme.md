# Create a Windows VM in Azure

![](https://guptanishith.com/wp-content/uploads/2021/11/Azure-VM-icon.png)

The script creates a windows VM in Azure.
The script also assumes that a Resource Group, vNet and a subnet is already in place.

### _Define Variables_

The script uses multiple variables to be passed as a value to the parameters/switches. These variables need to be defined in advance (_at the begining of the script_) before script can be executed.

- **VMImage -** Use **_az vm image list --output table_** to see a list of cached popular VM images in the Azure Marketplace. From the output, use **URNAlias** in the variable. Alternatively, you can use **URN** in the variable. The format of the URN in _Publisher:Offer:Sku:Version_. To use the latest version in URN, use **latest** rathen than defining the version number. For more information see [How to find Azure VM Image by using Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage). 
- **VMLocation -** Define location in which to create VM and related resources. If default location is not configured, will default to the resource group's location. Use **_az account list-locations -output table_** to find available locations. From the output, take the values in Name column and use it in the variable.
- **VMSize -** Default value is Standard_DS1_v2. Use az vm list-sizes --location <locationame> --output table in Azure CLI to fetch the list of available VM sizes in defined location. From the output, pick a values in the Name column and use it in the variable. 
- **DataDiskSize 1 or 2 -** Size of 1st and 2nd data disk in GBs. For example, 10, 20, etc. (_DataDiskSize1=10_). If only one data disk is required then place # at the begining of DataDiskSize2 and remove $DataDiskSize2 from az vm create command. If no data disk is required then place # at the beginning of DataDiskSize1 as well as DataDiskSize2 and also delete **--data-disk-sizes-gb** parameters from az vm create command.
- **VMOSDiskType -** Execute _az vm list-skus --location <locationname> --query "[].{ResourceType:resourceType,Name:name}[?ResourceType=='disks']" -output table_ to see available storage SKUs in the specified location. Pick a value from the Name column and use in the variable. Possible values are Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS, Premium_ZRS, and StandardSSD_ZRS
- **VMOSDiskSize -** When you create a new virtual machine (VM) in a resource group by deploying an image from Azure Marketplace, the default operating system (OS) drive is often 127 GB (some images have smaller OS disk sizes by default).
- **PipSKU -** Basic SKU: Basic Public IPs do not support Availability zones. Standard SKU: A Standard SKU public IP can be associated to a virtual machine or a load balancer front end. For more information, see Public IP SKUs in [Microsoft documentation](https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku).
