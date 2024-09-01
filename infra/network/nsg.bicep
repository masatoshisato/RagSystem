metadata description = 'Create a Azure Network Security Group by bicep template.'

targetScope = 'resourceGroup'

//  Common parameters for the resources.
param tags object

////////////////////////////////////////////////////////
// Parameters for the Network Security Group.

@description('The name of the Network Security Group.')
param name string

@description('The security rules of the Network Security Group.')
param securityRules array

// The Network Security Group.
// refer to : https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-bicep
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: name
  location: resourceGroup().location
  tags: tags

  properties: {
    securityRules: securityRules
  }
}

output nsgId string = nsg.id
