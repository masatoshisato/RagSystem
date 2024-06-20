targetScope = 'subscription'
param _rgName string
param _rgLocation string = 'japaneast'
param _deptName string = 'iocc'
param _ownerName string = 'iocc_sato'
param _utcShort string = utcNow('d')
param _deploymentName string = deployment().name

resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: _rgName
  location: _rgLocation
  tags: {
    dept: _deptName
    owner: _ownerName
    lastDeployed: _utcShort
    deploy: _deploymentName
  }
}
