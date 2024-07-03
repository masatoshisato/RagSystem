metadata description = 'Create a Azure Virtual Network by bicep template with some tags.'

targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of parameters for the resource.

// Common properties.
param Location string = resourceGroup().location
param DeptName string = 'default'
param DeploymentDate string = utcNow('d')
param DeploymentName string = deployment().name

// 

param vnetBastionSubnetName string = 'AzureBastionSubnet'
param vnetBastionSubnetPrefix string = '10.0.0.64/26'

////////////////////////////////////////////////////////////
// Resource definitions.

/*
 * VNet Definitions.
 */

// The name of the VNet.
param MainVNetName string = 'MainVNet'

// Address prefix for VNet.
param MainVNetAddressPrefix string = '10.0.0.0/16'

// VM encryption. (It must be enabled when using Bastion)
param MainVNetVMProtectionEnabled bool = true

// Traffic enctryption between VMs.
param MainVNetEncryptionEnabled bool = true

// DDoS protection for network.
param MainVNetDdosProtectionEnabled bool = false

resource MainVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {

	// Virtual network name.
  name: MainVNetName

	// resion.
  location: Location

	// tags.
  tags: {
    dept: DeptName
    lastDeployed: DeploymentDate
    deploy: DeploymentName
  }

  //////////////////// Property definitions for VNet.
  properties: {

		// Network address prefixes for VNET.
    addressSpace: {
      addressPrefixes: [
        MainVNetAddressPrefix
      ]
    }
    
    // Enables to encrypt the traffic between VMs.
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted' // This is Limitation to be set only 'AllowUnencrypted' by Microsoft.
      // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview#limitations
    }

    // Disables the ddos protection for network.
    enableDdosProtection: MainVNetDdosProtectionEnabled
  }
}

/*
 * AdminSubnet Definitions.
 */

// for AdminSubnet.
param AdminSubnetName string = 'AdminSubnet'
param AdminSubnetAddressPrefix string = '10.0.0.0/29'
param AdminSubnetPrivate bool = true
param AdminSubnetNATGateway bool = false
param AdminSubnetNSG string = 'NSG'
param AdminSubnetPrivateEndpointNetworkPolicies string = 'NSG'

resource AdminSubnet 'Microsoft.Network/virutalNetworks/subnets@2023-11-01' = {

  // Subnet name.
  name: AdminSubnetName

  // parent resource.
  parent: MainVNet

  // properties.
  properties: {

    // Address prefix for subnet.
    addressPrefix: _AdminSubnetAddressPrefix

          // Set to private subnet : Disabled to access outbound traffic of Basion.
          defaultOutboundAccess: false
        }
      }

      // AzureBastionSubnet
      {
        name: _vnetBastionSubnetName
        properties: {
          addressPrefix: _vnetBastionSubnetPrefix

          // Set to private subnet : Disabled to access outbound traffic of Basion.
          defaultOutboundAccess: false
        }
      }
    ]
  }
}
