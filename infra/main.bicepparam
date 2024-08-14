using './main.bicep'

param systemName = readEnvironmentVariable('SYSTEM_NAME')
param environmentName = readEnvironmentVariable('AZURE_ENV_NAME')
param location = readEnvironmentVariable('AZURE_LOCATION')
//param resourceGroupName = '${systemName}-${environmentName}'

////////////////////////////////////////////////////////////
// Parameters for the resource group.

// The name of the resource group, called as 'RagRg'.
param ragRg_name = readEnvironmentVariable('AZURE_RESOURCE_GROUP_NAME')

////////////////////////////////////////////////////////////
// Parameters for the virtual network.

// The RagSystem main virtual network, called as 'RagVNet'.
param ragVNet_name = '${systemName}-MainVnet-${environmentName}'
param ragVNet_addressPrefix = '10.0.0.0/16'
param ragVNet_encryptionEnabled = true
param ragVNet_ddosProtectionEnabled = false

// The management subnet, called as 'AdminSubnet'.
param adminSubnet_name = 'AdminSubnet'
param adminSubnet_addressPrefix = '10.0.0.0/29'
param adminSubnet_defaultOutboundAccess = false
param adminSubnet_privateEndpointNetworkPolicies = 'NetworkSecurityGroupEnabled'

// The bastion subnet, called as 'AzureBastionSubnet'.
param bastionSubnet_name = 'AzureBastionSubnet'
param bastionSubnet_addressPrefix = '10.0.0.64/26'
param bastionSubnet_defaultOutboundAccess = false
param bastionSubnet_privateEndpointNetworkPolicies = 'Disabled'

////////////////////////////////////////////////////////////
// Parameters for the Virtural Machines.

// The Network intafacce card of the AdminVm.
param adminVm_nic_name = '${systemName}-AdminVmNic-${environmentName}'
param adminVm_nic_ipConfiguration_name = 'ipconfig1'
param adminVm_nic_ipConfiguration_privateIPAllocationMethod = 'Dynamic'

// The virtual machine used for the management, called as 'AdminVm'.
param adminVm_name = '${systemName}-AdminVm-${environmentName}'
param adminVm_computerName = 'AdminHost'
param adminVm_osProfile_adminUsername = 'satoadmin'
@secure()
param adminVm_osProfile_adminPassword = '@HoAhoMan123!"#'
param adminVm_osProfile_provisionVMAgent = true
param adminVm_osProfile_enableAutomaticUpdates = true
param adminVm_osProfile_patchMode = 'AutomaticByPlatform'

// The hardware profiles of the AdminVm.
param adminVm_hardwareProfile_vmSize = 'Standard_D4as_v5'

// The security profiles of the AdminVm.
param adminVm_securityProfile_securityType = 'TrustedLaunch'
param adminVm_uefiSettings_secureBootEnabled = true
param adminVm_uefiSettings_vTpmEnabled = true

// The storage profiles of the AdminVm - OS disk.
param adminVm_osDisk_createOption = 'FromImage'
param adminVm_osDisk_managedDisk_storageAccountType = 'Premium_LRS'
param adminVm_osDisk_diskSizeGB = 128

// The storage profiles of the AdminVm - image reference.
param adminVm_imageReference_publisher = 'MicrosoftWindowsServer'
param adminVm_imageReference_offer = 'WindowsServer'
param adminVm_imageReference_sku = '2022-datacenter-azure-edition'
param adminVm_imageReference_version = 'latest'

// The diagnostics profiles of the AdminVm.
param adminVm_diagnosticsProfile_bootDiagnostics_enabled = true

// The additional capabilities of the AdminVm.
param adminVm_additionalCapabilities_hibernationEnabled = false

////////////////////////////////////////////////////////////
// Parameters for the Azure Bastion.

// The public IP address for the Azure Bastion.
param ragBastion_ip_name = '${systemName}-BastionIP-${environmentName}'
param ragBastion_ip_sku = 'Standard'
param ragBastion_ip_allocationMethod = 'Static'
param ragBastion_ip_ipVersion = 'IPv4'

// The Azure Bastion.
param ragBastion_name = '${systemName}-Bastion-${environmentName}'
param ragBastion_sku = 'Basic'
