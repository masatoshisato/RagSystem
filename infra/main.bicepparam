using './main.bicep'

param systemName = readEnvironmentVariable('SYSTEM_NAME')
param environmentName = readEnvironmentVariable('AZURE_ENV_NAME')
param location = readEnvironmentVariable('AZURE_LOCATION')
//param resourceGroupName = '${systemName}-${environmentName}'
param resourceGroupName = readEnvironmentVariable('AZURE_RESOURCE_GROUP_NAME')

// for the RagVNet
param ragVNet_name = '${systemName}-vnet-${environmentName}'
param ragVNet_addressPrefix = '10.0.0.0/16'
param ragVNet_encryptionEnabled = true
param ragVNet_ddosProtectionEnabled = false

// for the AdminSubnet
param adminSubnet_name = 'AdminSubnet'
param adminSubnet_addressPrefix = '10.0.0.0/29'
param adminSubnet_privateEnabled = true
param adminSubnet_privateEndpointNetworkPolicies = 'NetworkSecurityGroupEnabled'

// for the BastionSubnet
param bastionSubnet_name = 'AzureBastionSubnet'
param bastionSubnet_addressPrefix = '10.0.0.64/26'
param bastionSubnet_privateEnabled = true
param bastionSubnet_privateEndpointNetworkPolicies = 'Disabled'
