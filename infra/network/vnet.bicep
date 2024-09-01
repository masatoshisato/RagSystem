metadata description = 'Create a Azure Virtual Network by bicep template with some tags.'
targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of the virtual network.

// Parameter definitions for the RagVNet that is a main virtual network for the RagSystem.
@description('The name of the virtual network.')
param vNet_name string

@description('Common Region for the resources that is referenced from the resource group.')
param location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param tags object

@description('The address prefix for the RagVNet.')
param vNet_addressPrefix string

@description('Traffic encryption between VMs enabled.')
param vNet_encryptionEnabled bool

@description('DDoS protection for network enabled.')
param vNet_ddosProtectionEnabled bool

// Resource definition for the RagVNet.
// Refer to : https://learn.microsoft.com/ja-jp/azure/templates/microsoft.network/virtualnetworks?pivots=deployment-language-bicep
resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {

  // ** Required
  name: vNet_name

  location: location
  tags: tags

  properties: {

    // ** Optional
    enableDdosProtection: vNet_ddosProtectionEnabled

		// Network address prefixes for VNET.
    addressSpace: {
      addressPrefixes: [
        vNet_addressPrefix
      ]
    }
    
    // Enables to encrypt the traffic between VMs.
    encryption: {

      // ** Required
      enabled: vNet_encryptionEnabled

      // This property is limited to be set only 'AllowUnencrypted' by Microsoft.
      // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview#limitations
      enforcement: 'AllowUnencrypted' 
    }
  }
}

output vNetId string = vNet.id
