metadata description = 'Create a Azure Virtual Desktop Subnet by bicep template with some tags.'
targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// The definitions of the parameters of the subnet.

// Parameter definitions for the Subnet.
@description('The name of the Subnet.')
param subnet_name string

@description('The address prefix.')
param subnet_addressPrefix string

@description('The flag to enable the private subnet mode. This mode is used for explicitly blocking the internet access from the subnet.')
param subnet_defaultOutboundAccess bool

@description('The network policies for private endpoint.')
param subnet_privateEndpointNetworkPolicies string

@description('The virtual network that the subnet belongs to.')
param vnet_name string

param natGw_name string = ''

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnet_name
}

resource natGw 'Microsoft.Network/natGateways@2023-11-01' existing = if (!empty(natGw_name)) {
  name: natGw_name
}

// Resource definition for the Subnet.
// Refer to: https://learn.microsoft.com/ja-jp/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-bicep
resource subnet_relatedToNatGw 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = if (!empty(natGw_name)) {

  // ** Required
  name: subnet_name

  parent: vnet
  properties: {
    addressPrefix: subnet_addressPrefix

    // Private endpoint network policies. 
    // 'Disabled' / 'Enabled' / 'NetworkSecurityGroupEnabled' / 'RouteTableEnabled'
    privateEndpointNetworkPolicies : subnet_privateEndpointNetworkPolicies

    // Enable outbound access to the internet by default.
    // 'false' / 'true'
    defaultOutboundAccess: subnet_defaultOutboundAccess

    natGateway: {
      id: natGw.id
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = if (empty(natGw_name)) {

  // ** Required
  name: subnet_name

  parent: vnet
  properties: {
    addressPrefix: subnet_addressPrefix

    // Private endpoint network policies. 
    // 'Disabled' / 'Enabled' / 'NetworkSecurityGroupEnabled' / 'RouteTableEnabled'
    privateEndpointNetworkPolicies : subnet_privateEndpointNetworkPolicies

    // Enable outbound access to the internet by default.
    // 'false' / 'true'
    defaultOutboundAccess: subnet_defaultOutboundAccess
  }
}

output subnet object = (!empty(subnet)) ? subnet : subnet_relatedToNatGw
