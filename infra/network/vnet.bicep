metadata description = 'Create a Azure Virtual Network by bicep template with some tags.'

targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of common parameters for the resources.

@description('Common Region for the resources that is referenced from the resource group.')
param Location string = resourceGroup().location

@description('The managing department name of the resoruces. this value is put on a tag.')
param DeptName string = 'default'

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param DeploymentDate string = utcNow('d')

@description('The deployment name specified when the resources is deployed. This value is put on a tag.')
param DeploymentName string = deployment().name

////////////////////////////////////////////////////////////
// Definitions of the RagVNet.

@description('The name of the RagVNet.')
param RagVNetName string

@description('The address prefix for the RagVNet.')
param RagVNetAddressPrefix string

@description('Traffic encryption between VMs enabled.')
param RagVNetEncryptionEnabled bool

@description('DDoS protection for network enabled.')
param RagVNetDdosProtectionEnabled bool

resource RagVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {

  name: RagVNetName
  location: Location

  tags: {
    dept: DeptName
    lastDeployed: DeploymentDate
    deploy: DeploymentName
  }

  properties: {
    enableDdosProtection: RagVNetDdosProtectionEnabled

		// Network address prefixes for VNET.
    addressSpace: {
      addressPrefixes: [
        RagVNetAddressPrefix
      ]
    }
    
    // Enables to encrypt the traffic between VMs.
    encryption: {
      enabled: RagVNetEncryptionEnabled
      // This property is limited to be set only 'AllowUnencrypted' by Microsoft.
      // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview#limitations
      enforcement: 'AllowUnencrypted' 
    }
  }
}

//////////////////////////////////////////////////////////// 
// Definitions of the AdminSubnet for the RAG Application.

@description('The name of the AdminSubnet.')
param AdminSubnetName string

@description('The address prefix for the AdminSubnet.')
param AdminSubnetAddressPrefix string

@description('The flag to either enable(true) or disable(false) the private subnet.')
param AdminSubnetPrivateEnabled bool

@description('The network policies for private endpoint in the subnet.')
param AdminSubnetPrivateEndpointNetworkPolicies string

resource AdminSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {

  parent: RagVNet
  name: AdminSubnetName

  properties: {

    addressPrefix: AdminSubnetAddressPrefix

    // Private endpoint network policies. 
    // 'Disabled' to disable the network policies for the private endpoint.
    // 'Enabled' to enable the network policies for the private endpoint for both NSG and Route table
    // 'NetworkSecurityGroupEnabled' to enable the network policies for the private endpoint for only NSG
    // 'RouteTableEnabled' to enable the network policies for the private endpoint for only Route table
    privateEndpointNetworkPolicies : AdminSubnetPrivateEndpointNetworkPolicies

    // Private subnet flag
    // 'Disabled' to disable to send outbound traffic to the internet.
    // 'Enabled' to enable to send outbound traffic to the internet.
    defaultOutboundAccess: AdminSubnetPrivateEnabled
  }
}

//////////////////////////////////////////////////////////// 
// Definitions of the AzureBastionSubnet for the RAG Application.

@description('The name of the AzureBastionSubnet.')
param BastionSubnetName string

@description('The address prefix for the AzureBastionSubnet.')
param BastionSubnetAddressPrefix string

@description('The flag to enable the private for the subnet.')
param BastionSubnetPrivateEnabled bool

@description('Network policies for private endpoint in the subnet.')
param BastionSubnetPrivateEndpointNetworkPolicies string

resource BastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {

  parent: RagVNet
  name: BastionSubnetName

  properties: {

    addressPrefix: BastionSubnetAddressPrefix

    // Private endpoint network policies. 
    // 'Disabled' to disable the network policies for the private endpoint.
    // 'Enabled' to enable the network policies for the private endpoint for both NSG and Route table
    // 'NetworkSecurityGroupEnabled' to enable the network policies for the private endpoint for only NSG
    // 'RouteTableEnabled' to enable the network policies for the private endpoint for only Route table
    privateEndpointNetworkPolicies : BastionSubnetPrivateEndpointNetworkPolicies

    // Private subnet flag
    // 'Disabled' to disable to send outbound traffic to the internet.
    // 'Enabled' to enable to send outbound traffic to the internet.
    defaultOutboundAccess: BastionSubnetPrivateEnabled
  }
}
