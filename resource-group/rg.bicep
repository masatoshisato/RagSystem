metadata description = 'Create a Azure Resource Group by bicep template with some tags.'

targetScope = 'subscription'

////////////////////////////////////////////////////////////
// Definitions of parameters for the resources.

@description('Common Region for the resources that are created by this template.')
param _rgLocation string = 'japaneast'  

@description('Resource group name that you will create.')
param _rgName string

////////////////////////////////////////////////////////////
// Definition common tags for resources that are created by this template.
@description('The managing department name of the resoruces. this value is put on a tag.')
param _tagDeptName string = 'iocc'

@description('The managing owner name of thie resources. this value is put on a tag.')
param _tagOwnerName string = 'iocc_sato'

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param _tagUtcShort string = utcNow('d')

@description('The deployment name specified when the resources is deployed. This value is put on a tag.')
param _tagDeploymentName string = deployment().name

////////////////////////////////////////////////////////////
// Definitions of resources.

// Resource Groups.
resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: _rgName
  location: _rgLocation
  tags: {
    dept: _tagDeptName
    owner: _tagOwnerName
    lastDeployed: _tagUtcShort
    deploy: _tagDeploymentName
  }
}
