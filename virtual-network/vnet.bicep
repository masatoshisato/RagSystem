metadata description = 'Create a Azure Virtual Network by bicep template with some tags.'

targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of parameters for the resource.

param _location string = resourceGroup().location
param _vnetName string = 'MainVNet'
param _vnetAddressPrefix string = '10.0.0.0/16'
param _vnetAdminSubnetName string = 'AdminSubnet'
param _vnetAdminSubnetPrefix string = '10.0.0.0/29'
param _vnetBastionSubnetName string = 'AzureBastionSubnet'
param _vnetBastionSubnetPrefix string = '10.0.0.64/26'

param _deptName string = 'default'
param _utcShort string = utcNow('d')
param _deploymentName string = deployment().name

////////////////////////////////////////////////////////////
// Resource definitions.
resource MainVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {

	// Virtual network name.
  name: _vnetName

	// resion.
  location: _location

	// tags.
  tags: {
    dept: _deptName
    lastDeployed: _utcShort
    deploy: _deploymentName
  }

  //////////////////// Property definitions for VNet.
  properties: {

		// Network address prefixes for VNET.
    addressSpace: {
      addressPrefixes: [
        _vnetAddressPrefix
      ]
    }
    
    // Enables for VM when using Bastion. (It must be enabled when using Bastion)
    enableVmProtection: true

    // Enables to encrypt the traffic between VMs.
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted' // This is Limitation to be set only 'AllowUnencrypted' by Microsoft.
      // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview#limitations
    }

    // Disables the ddos protection for network.
    enableDdosProtection: false

    //////////////////// Subnet definitions.
    subnets: [

      // AdminSubnet
      {
        name: _vnetAdminSubnetName
        properties: {
          addressPrefix: _vnetAdminSubnetPrefix

          // Private Subnet : Azure Bastionのデフォルトアウトバウンドアクセスを無効化
          defaultOutboundAccess: false
        }
      }

      // AzureBastionSubnet
      {
        name: _vnetBastionSubnetName
        properties: {
          addressPrefix: _vnetBastionSubnetPrefix

          // Private Subnet : Azure Bastionのデフォルトアウトバウンドアクセスを無効化
          defaultOutboundAccess: false
        }
      }
    ]
  }
}
