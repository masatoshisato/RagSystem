metadata description = 'Create a KeyVault by bicep template with some tags.'
targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Parameters for the KeyVault
@description('The environment of the resource group.')
param environmentName string

@description('The system name of the resource group.')
param systemName string

@description('The tags to be applied to the resources.')
param tags object

@description('The SKU of the KeyVault.')
param kv_sku string

@description('The flag to enable the soft delete feature.')
param kv_enableSoftDelete bool

@description('The retention days of the soft delete feature.')
param kv_softDeleteRetentionInDays int

@description('The flag to enable the purge protection feature.')
param kv_enablePurgeProtection bool

@description('The flag to enable the RBAC authorization.')
param kv_enableRbacAuthorization bool

@description('The Addtional IP rules which is to enable access from if you want to specifiy the Azure Services bypass.')
param kv_ipRules array

////////////////////////////////////////////////////////////
// Variables for the KeyVault

@description('The version of the KeyVault')
var kv_version = '001'

@description('Name of the KeyVault')
var kv_name = '${systemName}-Kv-${kv_version}-${environmentName}'

// Resource definition for the KeyVault.
// Refer to : https://learn.microsoft.com/ja-jp/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep
resource Kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kv_name
  location: resourceGroup().location
  tags: tags

  properties: {
    sku: {
      family: 'A' // fixed value from Microsoft
      name: kv_sku
    }
    tenantId: tenant().tenantId

    // if you want to specify the bypass rule, you can set the ipRules.
    networkAcls: empty(kv_ipRules) ? null : {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: kv_ipRules
    }

    enableRbacAuthorization: kv_enableRbacAuthorization 

    // Enable the soft delete feature.
    enableSoftDelete: kv_enableSoftDelete
    softDeleteRetentionInDays: kv_softDeleteRetentionInDays

    // Enable the purge protection feature.
    // If you want to enable the purge protection, you need to enable the soft delete feature.
    enablePurgeProtection: (kv_enablePurgeProtection && kv_enableSoftDelete)

    publicNetworkAccess: 'Enabled'
  }
}

output kvName string = Kv.name
output kvId string = Kv.id
