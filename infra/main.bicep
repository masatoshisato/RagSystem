// This is the main bicep file for the RagSystem.

// Settings No.1 of the resource group scoped deployment.
// https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/resource-group-scoped-deployments
//
// To enable with resource group deployment, change the targetScope to 'resourceGroup'.
//targetScope = 'subscription'
targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of the common parameters for all the resources.

@description('System name that can be used as part of naming resource convention')
param systemName string

@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@description('Common Region for the resources that are created by this template.')
param location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param deploymentDate string = utcNow('d')

@description('The name of the resource group that is created in advance.')
param resourceGroupName string

////////////////////////////////////////////////////////////
// Definitions of common variables for all the resources.

@description('Tags that should be applied to all resources.')
var tags = {
  system: systemName
  env: environmentName
  lastDeployed: deploymentDate
}

// Settings No.4-1 of the resource group scoped deployment.
// https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/resource-group-scoped-deployments
// 
// Removed the definition of the resource group in this template. Instead of this, resource group name is defined in environment variables file and specified as a parameter.
//@description('The name of the resource group. This is used for specifying the scope of the module of the resources that is created in the resource group.')
//var rgName = '${systemName}-${environmentName}'

// Settings No.4-2 of the resource group scoped deployment.
// https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/resource-group-scoped-deployments
// 
// Disabled the definition of the resource group in the bicep file.

////////////////////////////////////////////////////////////
// Definitions of the resource group.
/*
@description('Create a Azure Resource Group by bicep template with some tags.')
module ragRg './resource-group/rg.bicep' = {

  scope: subscription()
  name: 'ragRg'

  params: {
    rgName: resourceGroupName
    location: location
    tags: tags
  }
}
*/

////////////////////////////////////////////////////////////
// Definitions of the virtual network.

// Parameter definitions for the RagVNet that is a main virtual networkf for the RagSystem.

@description('The name of the virtual network that is a main vnet for this system.')
param ragVNet_name string

@description('The address prefix for the RagVNet.')
param ragVNet_addressPrefix string

@description('The flag for the traffic encryption between VMs in the RagVNet.')
param ragVNet_encryptionEnabled bool

@description('The flag for the DDoS protection for network of the RagVNet.')
param ragVNet_ddosProtectionEnabled bool

// Parameter definitions for the AdminSubnet.

@description('The name of the AdminSubnet that is used for the management of this system from inside of the RagVNet.')
param adminSubnet_name string

@description('The address prefix for the AdminSubnet.')
param adminSubnet_addressPrefix string

@description('The flag for the private subnet mode for the AdminSubnet. This mode is used for explicitly blocking the internet access from the subnet.')
param adminSubnet_privateEnabled bool

@description('The flag for the private endpoint network policies for the AdminSubnet. This is used for the private endpoint connection to the subnet.')
param adminSubnet_privateEndpointNetworkPolicies string

// Parameter definitions for the BastionSubnet.

@description('The name of the BastionSubnet that is used for the Azure Bastion service.')
param bastionSubnet_name string

@description('The address prefix for the BastionSubnet.')
param bastionSubnet_addressPrefix string

@description('The flag for the private subnet mode for the BastionSubnet. This mode is used for explicitly blocking the internet access from the subnet.')
param bastionSubnet_privateEnabled bool

@description('The flag for the private endpoint network policies for the BastionSubnet. This is used for the private endpoint connection to the subnet.')
param bastionSubnet_privateEndpointNetworkPolicies string


module RagVNet './network/vnet.bicep' = {
  // scope: resourceGroup(RagRg)
  scope: resourceGroup(resourceGroupName)
  name: 'RagVNet'

  params: {
    location: location
    tags: tags
    
    // for the RagVNet that is a main virtual networkf for the RagSystem.
    ragVNet_name: ragVNet_name
    ragVNet_addressPrefix: ragVNet_addressPrefix
    ragVNet_encryptionEnabled: ragVNet_encryptionEnabled
    ragVNet_ddosProtectionEnabled: ragVNet_ddosProtectionEnabled

    // for the AdminSubnet
    adminSubnet_name: adminSubnet_name
    adminSubnet_addressPrefix: adminSubnet_addressPrefix
    adminSubnet_privateEnabled: adminSubnet_privateEnabled
    adminSubnet_privateEndpointNetworkPolicies: adminSubnet_privateEndpointNetworkPolicies

    // for the BastionSubnet
    bastionSubnet_name: bastionSubnet_name
    bastionSubnet_addressPrefix: bastionSubnet_addressPrefix
    bastionSubnet_privateEnabled: bastionSubnet_privateEnabled
    bastionSubnet_privateEndpointNetworkPolicies: bastionSubnet_privateEndpointNetworkPolicies
  }
  /*
  dependsOn: [
    ragRg
  ]
  */
}
