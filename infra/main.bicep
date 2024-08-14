// This is the main bicep file to build Azure Resources for the RagSystem.

targetScope = 'subscription'

////////////////////////////////////////////////////////////
// The common parameters and variables for all the resources.

@description('System name that can be used as part of naming resource convention')
param systemName string

@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@description('Common Region for the resources that are created by this template.')
param location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param deploymentDate string = utcNow('d')

@description('Tags that should be applied to all resources.')
var tags = {
  system: systemName
  env: environmentName
  lastDeployed: deploymentDate
}

////////////////////////////////////////////////////////////
// The resource group for the RagSystem (called as 'RagRg' below).

// Parameter definitions for the resource group.
@description('The name of the resource group')
param ragRg_name string

// Build the resource group.
@description('Create a Azure Resource Group by bicep template with some tags.')
module RagRg './resource-group/rg.bicep' = {

  scope: subscription()
  name: ragRg_name

  params: {
    rg_name: ragRg_name
    location: location
    tags: tags
  }
}

////////////////////////////////////////////////////////////
// The NAT Gateway for the RagSystem (called as 'RagNatGw' below).

// Parameters for the NAT Gateway.
@description('The name of the NAT Gateway.')
param ragNatGw_name string = 'RagSystem-NatGw-dev'

@description('The name of the public IP address for the NAT Gateway.')
param ragNatGw_Ip_name string = 'RagSystem-NatGwIP-dev'

// Build the NAT Gateway.
module RagNatGw './network/natgw.bicep' = {
  scope: resourceGroup(ragRg_name)
  name: ragNatGw_name
  params: {
    natGw_name: ragNatGw_name
    natGw_Ip_name: ragNatGw_Ip_name
    tags: tags
  }
  dependsOn: [
    RagRg
  ]
}

////////////////////////////////////////////////////////////
// The main virtual network for the RagSystem (called as 'RagVNet' below).

// Parameters for the RagVNet.
@description('The name of the virtual network that is a main vnet for this system.')
param ragVNet_name string

@description('The address prefix for the RagVNet.')
param ragVNet_addressPrefix string

@description('The flag for the traffic encryption between VMs in the RagVNet.')
param ragVNet_encryptionEnabled bool

@description('The flag for the DDoS protection for network of the RagVNet.')
param ragVNet_ddosProtectionEnabled bool

// Build the RagVNet.
module RagVNet './network/vnet.bicep' = {

  scope: resourceGroup(ragRg_name)
  name: ragVNet_name

  params: {
    location: location
    tags: tags
    
    vNet_name: ragVNet_name
    vNet_addressPrefix: ragVNet_addressPrefix
    vNet_encryptionEnabled: ragVNet_encryptionEnabled
    vNet_ddosProtectionEnabled: ragVNet_ddosProtectionEnabled
  }
  dependsOn: [
    RagRg
  ]
}

////////////////////////////////////////////////////////////
// The subnet of the RagVNet to manage the azure resources from inside of the RagVNet (called as 'AdminSubnet' below).

// Parameters for the AdminSubnet.
@description('The name of the AdminSubnet that is used for the management of this system from inside of the RagVNet.')
param adminSubnet_name string

@description('The address prefix for the AdminSubnet.')
param adminSubnet_addressPrefix string

@description('The flag for the private subnet mode for the AdminSubnet. This mode is used for explicitly blocking the internet access from the subnet.')
param adminSubnet_defaultOutboundAccess bool

@description('The flag for the private endpoint network policies for the AdminSubnet. This is used for the private endpoint connection to the subnet.')
param adminSubnet_privateEndpointNetworkPolicies string

// Build the AdminSubnet.
module AdminSubnet './network/subnet.bicep' = {

  scope: resourceGroup(ragRg_name)
  name: adminSubnet_name

  params: {
    subnet_name: adminSubnet_name
    subnet_addressPrefix: adminSubnet_addressPrefix
    subnet_defaultOutboundAccess: adminSubnet_defaultOutboundAccess
    subnet_privateEndpointNetworkPolicies: adminSubnet_privateEndpointNetworkPolicies
    vnet_name: ragVNet_name
    natGw_name: ragNatGw_name
  }
  dependsOn: [
    RagVNet
  ]
}

////////////////////////////////////////////////////////////
// The subnet of the RagVNet for dedicated to the Bastion (called as 'BastionSubnet' below).

// Parameters for the BastionSubnet.
@description('The name of the BastionSubnet that is used for the Azure Bastion service.')
param bastionSubnet_name string

@description('The address prefix for the BastionSubnet.')
param bastionSubnet_addressPrefix string

@description('The flag for the private subnet mode for the BastionSubnet. This mode is used for explicitly blocking the internet access from the subnet.')
param bastionSubnet_defaultOutboundAccess bool

@description('The flag for the private endpoint network policies for the BastionSubnet. This is used for the private endpoint connection to the subnet.')
param bastionSubnet_privateEndpointNetworkPolicies string

// Build the BastionSubnet.
module BastionSubnet './network/subnet.bicep' = {

  scope: resourceGroup(ragRg_name)
  name: bastionSubnet_name

  params: {
    subnet_name: bastionSubnet_name
    subnet_addressPrefix: bastionSubnet_addressPrefix
    subnet_defaultOutboundAccess: bastionSubnet_defaultOutboundAccess
    subnet_privateEndpointNetworkPolicies: bastionSubnet_privateEndpointNetworkPolicies
    vnet_name: ragVNet_name
    natGw_name: ragNatGw_name
  }
  dependsOn: [
    RagVNet
  ]
}

////////////////////////////////////////////////////////////
// The Virtual Machine for the management of the RagSystem (called as 'AdminVm' below).

// Parameters for the AdminVm network interface card.
@description('The name of the NIC for the AdminVm.')
param adminVm_nic_name string

@description('The name of the IP configuration for the NIC of the AdminVm.')
param adminVm_nic_ipConfiguration_name string

@description('The private IP allocation method for the NIC of the AdminVm.')
param adminVm_nic_ipConfiguration_privateIPAllocationMethod string

// Parameters for the virtual machine.
@description('The name of the AdminVm.')
param adminVm_name string

@description('The computer name of the AdminVm.')
param adminVm_computerName string

// Parameters for the os profile of the AdminVm.
@description('The admin username for the AdminVm.')
param adminVm_osProfile_adminUsername string

@description('The admin password for the AdminVm.')
@secure()
param adminVm_osProfile_adminPassword string

@description('The flag to provision the VM agent for the AdminVm.')
param adminVm_osProfile_provisionVMAgent bool

@description('The flag to enable the automatic updates for the AdminVm.')
param adminVm_osProfile_enableAutomaticUpdates bool

@description('The patch mode for the AdminVm.')
param adminVm_osProfile_patchMode string

// Parameters for the hardware profile of the AdminVm.
@description('The VM size for the AdminVm.')  
param adminVm_hardwareProfile_vmSize string

@description('The security type for the AdminVm.')
param adminVm_securityProfile_securityType string

@description('The flag to enable the secure boot for the AdminVm.')
param adminVm_uefiSettings_secureBootEnabled bool

@description('The flag to enable the vTPM for the AdminVm.')
param adminVm_uefiSettings_vTpmEnabled bool

// storage profiles - OS disk.
@description('The create option for the OS disk of the AdminVm.')
param adminVm_osDisk_createOption string

@description('The storage account type for the managed disk of the AdminVm.')
param adminVm_osDisk_managedDisk_storageAccountType string

@description('The disk size for the OS disk of the AdminVm.')
param adminVm_osDisk_diskSizeGB int

// storage profiles - image reference.
@description('The publisher for the image reference of the AdminVm.')
param adminVm_imageReference_publisher string

@description('The offer for the image reference of the AdminVm.')
param adminVm_imageReference_offer string

@description('The SKU for the image reference of the AdminVm.')
param adminVm_imageReference_sku string

@description('The version for the image reference of the AdminVm.')
param adminVm_imageReference_version string

// diagnostics profiles.
@description('The flag to enable the boot diagnostics for the AdminVm.')
param adminVm_diagnosticsProfile_bootDiagnostics_enabled bool

// additional capabilities.
@description('The flag to enable the hibernation for the AdminVm.')
param adminVm_additionalCapabilities_hibernationEnabled bool

// Build the AdminVm.
module AdminVm './compute/vm.bicep' = {
  scope: resourceGroup(ragRg_name)
  name: adminVm_name
  params: {
    // Common parameters
    location: location
    tags: tags

    // Parameters for the NIC of the AVD session host VM.
    nic_name: adminVm_nic_name
    nic_ipConfiguration_name: adminVm_nic_ipConfiguration_name
    nic_ipConfiguration_privateIPAllocationMethod: adminVm_nic_ipConfiguration_privateIPAllocationMethod

    // Parameters for the AVD session host VM.
    vm_name: adminVm_name
    vm_associatedVNetName: ragVNet_name
    vm_associatedSubnetName: adminSubnet_name
    vm_computerName: adminVm_computerName

    // os profiles.
    vm_osProfile_adminUsername: adminVm_osProfile_adminUsername
    vm_osProfile_adminPassword: adminVm_osProfile_adminPassword
    vm_osProfile_provisionVMAgent: adminVm_osProfile_provisionVMAgent
    vm_osProfile_enableAutomaticUpdates: adminVm_osProfile_enableAutomaticUpdates
    vm_osProfile_patchMode: adminVm_osProfile_patchMode

    // hardware profiles.
    vm_hardwareProfile_vmSize: adminVm_hardwareProfile_vmSize

    // security profiles.
    vm_securityProfile_securityType: adminVm_securityProfile_securityType
    vm_uefiSettings_secureBootEnabled: adminVm_uefiSettings_secureBootEnabled
    vm_uefiSettings_vTpmEnabled: adminVm_uefiSettings_vTpmEnabled

    // storage profiles - OS disk.
    vm_osDisk_createOption: adminVm_osDisk_createOption
    vm_osDisk_managedDisk_storageAccountType: adminVm_osDisk_managedDisk_storageAccountType
    vm_osDisk_diskSizeGB: adminVm_osDisk_diskSizeGB

    // storage profiles - image reference.
    vm_imageReference_publisher: adminVm_imageReference_publisher
    vm_imageReference_offer: adminVm_imageReference_offer
    vm_imageReference_sku: adminVm_imageReference_sku
    vm_imageReference_version: adminVm_imageReference_version

    // diagnostics profiles.
    vm_diagnosticsProfile_bootDiagnostics_enabled: adminVm_diagnosticsProfile_bootDiagnostics_enabled

    // additional capabilities.
    vm_additionalCapabilities_hibernationEnabled: adminVm_additionalCapabilities_hibernationEnabled
  }

  dependsOn: [
    AdminSubnet
  ]
}

////////////////////////////////////////////////////////////
// The Azure Bastion for the RagSystem (called as 'RagSystem-Bastion' below).

// Parameters for the public IP address of the Bastion.
@description('The name of the public IP address for the Bastion.')
param ragBastion_ip_name string = 'RagSystem-Bastion-IP-dev'

@description('The SKU for the public IP address of the Bastion.')
param ragBastion_ip_sku string = 'Standard'

@description('The allocation method for the public IP address of the Bastion.')
param ragBastion_ip_allocationMethod string = 'Static'

@description('The IP version for the public IP address of the Bastion.')
param ragBastion_ip_ipVersion string = 'IPv4'

// Parameters for the Azure Bastion.
@description('The name of the Azure Bastion.')
param ragBastion_name string = 'RagSystem-Bastion-dev'

@description('The SKU for the Azure Bastion.')
param ragBastion_sku string = 'Standard'

// Build the Bastion.
module RagSystemBastion './network/bastion.bicep' = {
  scope: resourceGroup(ragRg_name)
  name: 'RagSystem-Bastion-dev'
  params: {

    // common parameters
    tags: tags

    // Associated VNet name and Subnet name for the Bastion.
    associatedVnet_name: ragVNet_name
    associatedSubnet_name: bastionSubnet_name

    // parameters for the public IP address of the Bastion.
    bastion_ip_name: ragBastion_ip_name
    bastion_ip_sku: ragBastion_ip_sku
    bastion_ip_allocationMethod: ragBastion_ip_allocationMethod
    bastion_ip_ipVersion: ragBastion_ip_ipVersion

    // parameters for the Bastion.
    bastion_name: ragBastion_name
    bastion_sku: ragBastion_sku
  }
  dependsOn: [
    BastionSubnet
  ]
}
