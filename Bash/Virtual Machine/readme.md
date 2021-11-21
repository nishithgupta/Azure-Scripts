The script creates a windows VM in Azure.

The scripts assumes that a Resource Group, vNet and a subnet is already in place.

- **VMImage -** Use **_az vm image list --output table_** to see a list of cached popular VM images in the Azure Marketplace. From the output, use **URNAlias** in the variable. Alternatively, you can use **URN** in the variable. The format of the URN in _Publisher:Offer:Sku:Version_. To use the latest version in URN, use **latest** rathen than defining the version number. For more information see [How to find Azure VM Image by using Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage). 
- **VMLocation -** Define location in which to create VM and related resources. If default location is not configured, will default to the resource group's location. Use **_az account list-locations -output table_** to find available locations. From the output, 
- **VMSize -** Default value is Standard_DS1_v2. Use az vm list-sizes in Azure CLI to
- **DataDiskSize 1 or 2 -** Size of 1st and 2nd data disk in GBs. For example, 10, 20, etc. (_DataDiskSize1=10_). If only one data disk is required then place # at the begining of DataDiskSize2 and remove $DataDiskSize2 from az vm create command. If no data disk is required then place # at the beginning of DataDiskSize1 as well as DataDiskSize2 and also delete **--data-disk-sizes-gb** parameters from az vm create command.
