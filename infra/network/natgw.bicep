metadata description = 'Create a Azure NAT Gateway by bicep template.'

targetScope = 'resourceGroup'

param natGw_Ip_name string = 'RagSystem-NatGwIP-dev'

resource natGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: natGw_Ip_name
  location: resourceGroup().location
  tags: tags

  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

param natGw_name string = 'RagSystem-NatGw-dev'
param tags object

resource natGw 'Microsoft.Network/natGateways@2024-01-01' = {
  name: natGw_name
  location: resourceGroup().location
  tags: tags

  sku: {
    name: 'Standard'
  }

  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGatewayPublicIP.id
      }
    ]
  }
}

output natGw object = natGw
