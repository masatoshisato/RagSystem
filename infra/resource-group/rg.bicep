metadata description = 'Create a Azure Resource Group by bicep template with some tags.'

targetScope = 'subscription'

////////////////////////////////////////////////////////////
// Definitions of common parameters for the resources.

// Common properties.

@minLength(1)
@maxLength(64)
@description('System name that can be used as part of naming resource convention')
param systemName string

@description('Name of the environment that can be used as part of naming resource convention')
param envName string

@description('Common Region for the resources that are created by this template.')
param location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param tags object

////////////////////////////////////////////////////////////
// Definitions of the Resource Group.

resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {

  // Main part of the resource.
  name: '${systemName}-${envName}'
  location: location

  // tags.
  tags: tags
}
