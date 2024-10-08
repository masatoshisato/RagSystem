metadata description = 'Create a Azure Resource Group by bicep template with some tags.'

targetScope = 'subscription'

////////////////////////////////////////////////////////////
// Definitions of the Resource Group.

// Parameter definitions for the Resource Group.
@description('System name that can be used as part of naming resource convention')
param rg_name string

@description('Common Region for the resources that are created by this template.')
param location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param tags object

// Resource definition for the Resource Group.
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {

  name: rg_name
  location: location
  tags: tags
}

output rgId string = rg.id
