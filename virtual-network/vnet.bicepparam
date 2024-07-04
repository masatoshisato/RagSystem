using './vnet.bicep'

param RagVNetName = 'RagVNet'
param RagVNetAddressPrefix = '10.0.0.0/16'
param RagVNetEncryptionEnabled = true
param RagVNetDdosProtectionEnabled = false

param AdminSubnetName = 'AdminSubnet'
param AdminSubnetAddressPrefix = '10.0.0.0/29'
param AdminSubnetPrivateEnabled = true
param AdminSubnetPrivateEndpointNetworkPolicies = 'NetworkSecurityGroupEnabled'

param BastionSubnetName = 'AzureBastionSubnet'
param BastionSubnetAddressPrefix = '10.0.0.64/26'
param BastionSubnetPrivateEnabled = true
param BastionSubnetPrivateEndpointNetworkPolicies = 'Disabled'
