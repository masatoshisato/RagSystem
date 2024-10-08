metadata description = 'Create a KeyVault by bicep template with some tags.'
targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Parameters for Secret.
@description('Name of the KeyVault')
param kv_name string

// The Subnet that the Azure Bastion belongs to.
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kv_name
}

resource SecretRagSystemAdminVmLocalAdminPassword 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: kv
  name: 'RagSystemAdminVmLocalAdminPassword'
  properties: {
    value: uniqueString('RagSystemAdminVmLocalAdminPassword')
  }
}
