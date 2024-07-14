metadata description = 'Create a Azure Resource Group by bicep template with some tags.'

targetScope = 'subscription'

////////////////////////////////////////////////////////////
// Definitions of common parameters for the resources.

// Common properties.
@description('Common Region for the resources that are created by this template.')
param Location string = 'japaneast'

@description('The managing department name of the resoruces. this value is put on a tag.')
param DeptName string = 'default'

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param DeploymentDate string = utcNow('d')

@description('The deployment name specified when the resources is deployed. This value is put on a tag.')
param DeploymentName string = deployment().name

////////////////////////////////////////////////////////////
// Definitions of the Resource Group.

@description('Resource group name that you will create.')
param RgName string

resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {

  // Main part of the resource.
  name: RgName
  location: Location

  // tags.
  tags: {
    dept: DeptName
    lastDeployed: DeploymentDate
    deploy: DeploymentName
  }
}
