metadata description = 'Create a Azure IP by bicep template.'

targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Common parameters for the resources.

// The tags of the resource.
param tags object

////////////////////////////////////////////////////////////
// The definitions of the public IP address.

// Parameters for the public IP address.
param name string

// The public IP address.
resource publicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: name
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

output publicIpId string = publicIp.id
