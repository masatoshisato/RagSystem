// This is the Bicep file that defines the Azure Bastion.
// The Azure Bastion is a service that provides secure and seamless RDP and SSH access to the Azure VMs over the SSL.

metadata description = 'Create a Azure Bastion by bicep template.'

targetScope = 'resourceGroup'

//  Common parameters for the resources.
param tags object

////////////////////////////////////////////////////////////
// Parameters for the Public IP Address of the Azure Bastion.

@description('The name of the Public IP Address of the Azure Bastion.')
param bastion_ip_name string

// The Public IP Address of the Azure Bastion.
module bastionIp './public-ip.bicep' = {
  name: bastion_ip_name

  params : {
    name: bastion_ip_name
    tags: tags
  }
}

////////////////////////////////////////////////////////////
// Parameters for the Azure Bastion.

@description('The name of the Azure Bastion.')
param bastion_name string

@description('The SKU of the Azure Bastion.')
param bastion_sku string

@description('The Virtual Network that the Azure Bastion belongs to.')
param associatedVnet_name string

@description('The Subnet that the Azure Bastion belongs to.')
param associatedSubnet_name string

// The Subnet that the Azure Bastion belongs to.
resource parentSbunet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  name: '${associatedVnet_name}/${associatedSubnet_name}'
}

// The Azure Bastion.
resource bastion 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: bastion_name
  location: resourceGroup().location
  tags: tags

  sku: {
    name: bastion_sku
  }

  properties: {
    disableCopyPaste: false

    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: parentSbunet.id
          }
          publicIPAddress: {
            id: bastionIp.outputs.publicIpId
          }
        }
      }
    ]
  }
}

output bastionId string = bastion.id
output bastionName string = bastion.name
