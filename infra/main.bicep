// This is the main bicep file to build Azure Resources for the Rag.

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
// The resource group for the Rag (named as 'Rg' below).

// Parameters for the resource group.
@description('The name of the resource group')
param rg_name string

// Build the resource group.
@description('Create a Azure Resource Group by bicep template with some tags.')
module Rg './resource-group/rg.bicep' = {

  scope: subscription()
  name: rg_name

  params: {
    rg_name: rg_name
    location: location
    tags: tags
  }
}

////////////////////////////////////////////////////////////
// The NAT Gateway for the Rag (named as 'NatGw' below).

// Parameters for the NAT Gateway.
@description('The name of the NAT Gateway.')
param natGw_name string

@description('The name of the public IP address for the NAT Gateway.')
param natGw_Ip_name string

// Build the NAT Gateway.
module NatGw './network/nat-gw.bicep' = {
  scope: resourceGroup(rg_name)
  name: natGw_name
  params: {
    natGw_name: natGw_name
    natGw_Ip_name: natGw_Ip_name
    tags: tags
  }
  dependsOn: [
    Rg
  ]
}

////////////////////////////////////////////////////////////
// The main virtual network for the Rag (named as 'MainVNet' below).

// Parameters for the MainVNet.
@description('The name of the virtual network that is a main vnet for this system.')
param mainVNet_name string

@description('The address prefix for the MainVNet.')
param mainVNet_addressPrefix string

@description('The flag for the traffic encryption between VMs in the MainVNet.')
param mainVNet_encryptionEnabled bool

@description('The flag for the DDoS protection for network of the MainVNet.')
param mainVNet_ddosProtectionEnabled bool

// Build the MainVNet.
module MainVNet './network/vnet.bicep' = {

  scope: resourceGroup(rg_name)
  name: mainVNet_name

  params: {
    location: location
    tags: tags
    
    vNet_name: mainVNet_name
    vNet_addressPrefix: mainVNet_addressPrefix
    vNet_encryptionEnabled: mainVNet_encryptionEnabled
    vNet_ddosProtectionEnabled: mainVNet_ddosProtectionEnabled
  }
  dependsOn: [
    Rg
  ]
}

////////////////////////////////////////////////////////////
// The subnet of the RagVNet to manage the azure resources from inside of the RagVNet (named as 'AdminSubnet' below).

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

  scope: resourceGroup(rg_name)
  name: adminSubnet_name

  params: {
    subnet_name: adminSubnet_name
    subnet_addressPrefix: adminSubnet_addressPrefix
    subnet_defaultOutboundAccess: adminSubnet_defaultOutboundAccess
    subnet_privateEndpointNetworkPolicies: adminSubnet_privateEndpointNetworkPolicies
    vnet_name: mainVNet_name
    natGw_name: natGw_name
  }
  dependsOn: [
    MainVNet
    NatGw
  ]
}

////////////////////////////////////////////////////////////
// The subnet of the RagVNet for dedicated to the Bastion (named as 'BastionSubnet' below).

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

  scope: resourceGroup(rg_name)
  name: bastionSubnet_name

  params: {
    subnet_name: bastionSubnet_name
    subnet_addressPrefix: bastionSubnet_addressPrefix
    subnet_defaultOutboundAccess: bastionSubnet_defaultOutboundAccess
    subnet_privateEndpointNetworkPolicies: bastionSubnet_privateEndpointNetworkPolicies
    vnet_name: mainVNet_name
    // natGw_name: natGw_name
    nsg_name: bastionNsg_name
  }
  dependsOn: [
    MainVNet
    // NatGw
    BastionNsg
  ]
}

////////////////////////////////////////////////////////////
// The subnet of the RagVNet for dedicated to the VPN Gateway (named as 'GatewaySubnet' below).

@description('The name of the GatewaySubnet that is used for the VPN Gateway.')
param gatewaySubnet_name string

@description('The address prefix for the GatewaySubnet.')
param gatewaySubnet_addressPrefix string

@description('The flag for the private subnet mode for the GatewaySubnet. This mode is used for explicitly blocking the internet access from the subnet.')
param gatewaySubnet_defaultOutboundAccess bool = false

@description('The flag for the private endpoint network policies for the GatewaySubnet. This is used for the private endpoint connection to the subnet.')
param gatewaySubnet_privateEndpointNetworkPolicies string

// Build the GatewaySubnet.
module GatewaySubnet './network/subnet.bicep' = {

  scope: resourceGroup(rg_name)
  name: gatewaySubnet_name

  params: {
    subnet_name: gatewaySubnet_name
    subnet_addressPrefix: gatewaySubnet_addressPrefix
    subnet_defaultOutboundAccess: gatewaySubnet_defaultOutboundAccess
    subnet_privateEndpointNetworkPolicies: gatewaySubnet_privateEndpointNetworkPolicies
    vnet_name: mainVNet_name
  }
  dependsOn: [
    MainVNet
  ]
}


////////////////////////////////////////////////////////////
// The Virtual Machine for the management of the Rag (named as 'AdminVm' below).

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
  scope: resourceGroup(rg_name)
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
    vm_associatedVNetName: mainVNet_name
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
// The Azure Bastion for the Rag (named as 'Bastion' below).

// Parameters for the public IP address of the Bastion.
@description('The name of the public IP address for the Bastion.')
param bastion_ip_name string

// Parameters for the Bastion.
@description('The name of the Bastion.')
param bastion_name string

@description('The SKU for the Bastion.')
param bastion_sku string

// Build the Bastion.
module Bastion './network/bastion.bicep' = {
  scope: resourceGroup(rg_name)
  name: bastion_name
  params: {

    // common parameters
    tags: tags

    // Associated VNet name and Subnet name for the Bastion.
    associatedVnet_name: mainVNet_name
    associatedSubnet_name: bastionSubnet_name

    // parameters for the public IP address of the Bastion.
    bastion_ip_name: bastion_ip_name

    // parameters for the Bastion.
    bastion_name: bastion_name
    bastion_sku: bastion_sku
  }
  dependsOn: [
    BastionSubnet
  ]
}

//////////////////////////////////////////////////////////// 
// The Network Security Group for the Azure Bastion Subnet (named as 'BastionNsg' below).
@description('The name of the Network Security Group for the Azure Bastion Subnet.')
param bastionNsg_name string

@description('The outbound security rules of the Network Security Group for the Azure Bastion Subnet.')
param bastionNsg_securityRules_outBound array 

@description('The inboud security rules of the Network Security Group for the Azure Bastion Subnet.')
param bastionNsg_securityRules_inBound array

@description('The security rules of the Network Security Group for the Azure Bastion Subnet.')
var bastionNsg_securityRules = concat(bastionNsg_securityRules_outBound, bastionNsg_securityRules_inBound)

// Build the Network Security Group for the AzureBastionSubnet.
module BastionNsg './network/nsg.bicep' = {
  scope: resourceGroup(rg_name)
  name: bastionNsg_name
  params: {
    tags: tags
    name: bastionNsg_name
    securityRules: bastionNsg_securityRules
  }
  dependsOn: [
    Rg
  ]
}

////////////////////////////////////////////////////////////
// The VPN Gateway for the Rag (named as 'P2SVpn' below).

@description('The name of the VPN Gateway.')
param vpnGateway_name string

@description('The gateway type for the VPN Gateway.')
param vpnGateway_gatewayType string

@description('The SKU for the VPN Gateway.')
param vpnGateway_sku string

@description('The generation for the VPN Gateway.')
param vpnGateway_generation string

@description('The name of the public IP address 1 for the VPN Gateway.')
param vpnGateway_ip1_name string

@description('The name of the public IP address 2 for the VPN Gateway.')
param vpnGateway_ip2_name string

@description('The flag to configure the BGP for the VPN Gateway.')
param vpnGateway_configureBgp bool

@description('The address pool for the VPN clients.')
param vpnGateway_addressPool string

@description('The tunnel type for the VPN. For example, "OpenVPN".')
param vpnGateway_tunnelType string

@description('The authentication type for the VPN. For example, "AAD".')
param vpnGateway_authenticationType string

@description('The name of the public IP address for the user VPN entry point.')
param vpnGateway_userVpnPublicIpName string

// Build the VPN Gateway.
module P2SVpn './network/vpn-gw.bicep' = {
  scope: resourceGroup(rg_name)
  name: vpnGateway_name
  params: {
    tags: tags
    location: location
    vpnGatewayName: vpnGateway_name
    gatewayType: vpnGateway_gatewayType
    sku: vpnGateway_sku
    generation: vpnGateway_generation
    virtualNetworkName: mainVNet_name
    subnetName: gatewaySubnet_name
    vpnIp1Name: vpnGateway_ip1_name
    vpnIp2Name: vpnGateway_ip2_name
    configureBgp: vpnGateway_configureBgp
    addressPool: vpnGateway_addressPool
    tunnelType: vpnGateway_tunnelType
    authenticationType: vpnGateway_authenticationType
    vpnEntryPointIpName: vpnGateway_userVpnPublicIpName
  }
  dependsOn: [
    MainVNet
    GatewaySubnet
  ] 
}

////////////////////////////////////////////////////////////
// KeyVault for the Rag (named as 'kv' below).

// Parameters for kv.
@description('The SKU of the KeyVault.')
param kv_sku string = 'standard'

@description('The flag to enable the soft delete feature.')
param kv_enableSoftDelete bool = true

@description('The retention days of the soft delete feature.')
param kv_softDeleteRetentionInDays int = 90

@description('The flag to enable the purge protection feature.')
param kv_enablePurgeProtection bool = true

@description('The flag to enable the RBAC authorization.')
param kv_enableRbacAuthorization bool = true

@description('The Addtional IP rules which is to enable access from if you want to specifiy the Azure Services bypass.')
param kv_ipRules array = [
  {
    value: '114.150.248.139/32' // Your IP address
  }
  {
    value: '103.5.140.0/22' // from W2wifi
  }
  {
    value: '106.154.180.0/24' // from W2wifi
  }
]

// Build kvAdminVm.
module Kv './keyvault/keyvault.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'kv'
  params: {
    tags: tags
    environmentName: environmentName
    systemName: systemName
    kv_sku: kv_sku
    kv_enableSoftDelete: kv_enableSoftDelete
    kv_softDeleteRetentionInDays: kv_softDeleteRetentionInDays
    kv_enablePurgeProtection: kv_enablePurgeProtection
    kv_enableRbacAuthorization: kv_enableRbacAuthorization
    kv_ipRules: kv_ipRules
  }
  dependsOn: [
    Rg
  ]
}

// Secret for the AdminVm.
module KvAdminVmSecret './keyvault/secret.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'kvAdminVmSecret'
  params: {
    kv_name: Kv.outputs.kvName
  }
  dependsOn: [
    Kv
  ]
}

output rg_id string = Rg.outputs.rgId
output adminVm_name string = AdminVm.outputs.vmName
output adminVm_id string = AdminVm.outputs.vmId
output adminVm_nic_name string = AdminVm.outputs.vmNicName
output adminVm_nic_id string = AdminVm.outputs.vmNicId
output bastion_name string = Bastion.outputs.bastionName
output bastion_id string = Bastion.outputs.bastionId
output vNet_name string = MainVNet.outputs.vNetName
output vNet_id string = MainVNet.outputs.vNetId
output kv_name string = Kv.outputs.kvName
output kv_id string = Kv.outputs.kvId
