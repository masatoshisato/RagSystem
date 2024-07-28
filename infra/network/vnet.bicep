metadata description = 'Create a Azure Virtual Network by bicep template with some tags.'

// Settings No.2 of the resource group scoped deployment.
// https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/resource-group-scoped-deployments
// 
// To enable with resource group deployment, this is needed to be disabled.
//targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of the virtual network.

// Parameter definitions for the RagVNet that is a main virtual network for the RagSystem.
@description('The name of the virtual network.')
param ragVNet_name string

@description('Common Region for the resources that is referenced from the resource group.')
param location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param tags object

@description('The address prefix for the RagVNet.')
param ragVNet_addressPrefix string

@description('Traffic encryption between VMs enabled.')
param ragVNet_encryptionEnabled bool

@description('DDoS protection for network enabled.')
param ragVNet_ddosProtectionEnabled bool

// Resource definition for the RagVNet.
resource RagVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {

  name: ragVNet_name
  location: location
  tags: tags

  properties: {
    enableDdosProtection: ragVNet_ddosProtectionEnabled

		// Network address prefixes for VNET.
    addressSpace: {
      addressPrefixes: [
        ragVNet_addressPrefix
      ]
    }
    
    // Enables to encrypt the traffic between VMs.
    encryption: {
      enabled: ragVNet_encryptionEnabled
      // This property is limited to be set only 'AllowUnencrypted' by Microsoft.
      // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview#limitations
      enforcement: 'AllowUnencrypted' 
    }
  }
}

// Definitions of the AdminSubnet of the RagVNet.
@description('The name of the AdminSubnet.')
param adminSubnet_name string

@description('The address prefix for the AdminSubnet.')
param adminSubnet_addressPrefix string

@description('The flag to either enable(true) or disable(false) the private subnet.')
param adminSubnet_privateEnabled bool

@description('The network policies for private endpoint in the subnet.')
param adminSubnet_privateEndpointNetworkPolicies string

// Resource definition for the AdminSubnet.
resource AdminSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {

  parent: RagVNet
  name: adminSubnet_name

  properties: {

    addressPrefix: adminSubnet_addressPrefix

    // Private endpoint network policies. 
    // 'Disabled' to disable the network policies for the private endpoint.
    // 'Enabled' to enable the network policies for the private endpoint for both NSG and Route table
    // 'NetworkSecurityGroupEnabled' to enable the network policies for the private endpoint for only NSG
    // 'RouteTableEnabled' to enable the network policies for the private endpoint for only Route table
    privateEndpointNetworkPolicies : adminSubnet_privateEndpointNetworkPolicies

    // Private subnet flag
    // 'Disabled' to disable to send outbound traffic to the internet.
    // 'Enabled' to enable to send outbound traffic to the internet.
    defaultOutboundAccess: adminSubnet_privateEnabled
  }
}

// Definitions of the BastionSubnet of the RagVNet.
@description('The name of the AzureBastionSubnet.')
param bastionSubnet_name string

@description('The address prefix for the AzureBastionSubnet.')
param bastionSubnet_addressPrefix string

@description('The flag to enable the private for the subnet.')
param bastionSubnet_privateEnabled bool

@description('Network policies for private endpoint in the subnet.')
param bastionSubnet_privateEndpointNetworkPolicies string

// Resource definition for the BastionSubnet.
resource BastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {

  parent: RagVNet
  name: bastionSubnet_name

  properties: {

    addressPrefix: bastionSubnet_addressPrefix

    // Private endpoint network policies. 
    // 'Disabled' to disable the network policies for the private endpoint.
    // 'Enabled' to enable the network policies for the private endpoint for both NSG and Route table
    // 'NetworkSecurityGroupEnabled' to enable the network policies for the private endpoint for only NSG
    // 'RouteTableEnabled' to enable the network policies for the private endpoint for only Route table
    privateEndpointNetworkPolicies : bastionSubnet_privateEndpointNetworkPolicies

    // Private subnet flag
    // 'Disabled' to disable to send outbound traffic to the internet.
    // 'Enabled' to enable to send outbound traffic to the internet.
    defaultOutboundAccess: bastionSubnet_privateEnabled
  }
}
