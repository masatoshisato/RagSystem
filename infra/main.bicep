targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param EnvironmentName string

// Common properties.
@description('System name that can be used as part of naming resource convention')
param SystemName string

@description('Common Region for the resources that are created by this template.')
param Location string

@description('Created date of the resources. formatted as "dd/MM/yyyy". This value is put on a tag.')
param DeploymentDate string = utcNow('d')

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  system: SystemName
  env: EnvironmentName
  lastDeployed: DeploymentDate
}

// Create a resource group.
module rg './resource-group/rg.bicep' = {
  name: 'rg'
  params: {
    systemName: SystemName
    envName: EnvironmentName
    location: Location
    tags: tags
  }
}
