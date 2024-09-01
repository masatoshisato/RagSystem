metadata description = 'Create a Azure NAT Gateway by bicep template.'

targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Common parameters for the resources.
param tags object

////////////////////////////////////////////////////////////
// The definitions of the NAT Gateway.

// Parameters for the public IP address of the NAT Gateway.
param natGw_Ip_name string = 'RagSystem-NatGwIP-dev'

// The public IP address for the NAT Gateway.
module natGwPublicIp './public-ip.bicep' = {
  name: 'natGatewayPublicIP'
  params: {
    name: natGw_Ip_name
    tags: tags
  }
}

// Parameters for the NAT Gateway.
param natGw_name string = 'RagSystem-NatGw-dev'

// The NAT Gateway.
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
        id: natGwPublicIp.outputs.publicIpId
      }
    ]
  }
  dependsOn: [
    natGwPublicIp
  ]
}

output natGwId string = natGw.id
