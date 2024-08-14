// refer to:
// https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep

metadata description = 'Create a Azure Virtual Desktop Session Host VM by bicep template.'

targetScope = 'resourceGroup'

//////////////////////////////////////////////////////////// 
// Parameters for each resource.
param location string
param tags object

////////////////////////////////////////////////////////////
// Parameters of the Subnet to associate with the AVD session host VM (NIC).
param vm_associatedVNetName string
param vm_associatedSubnetName string

////////////////////////////////////////////////////////////
// Subnet definition for the AVD session host VM (NIC).
resource avdSessionHostVmSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vm_associatedVNetName}/${vm_associatedSubnetName}'
}

////////////////////////////////////////////////////////////
// Parameters of the NIC.
param nic_name string
param nic_ipConfiguration_name string
param nic_ipConfiguration_privateIPAllocationMethod string

//////////////////////////////////////////////////////////// 
// NIC definition for the AVD session host VM.
resource avdSessionHostVmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nic_name
  location: location
  tags: tags

  properties: {
    ipConfigurations: [
      {
        name: nic_ipConfiguration_name
        properties: {
          subnet: {
            id: avdSessionHostVmSubnet.id
          }
          privateIPAllocationMethod: nic_ipConfiguration_privateIPAllocationMethod
        }
      }
    ]
  }
  dependsOn: [
    avdSessionHostVmSubnet
  ]
}

////////////////////////////////////////////////////////////
// Parameters of the AVD session host VM.
param vm_name string = 'RagSystem-AdminAvd-Vm-dev'
param vm_computerName string = 'AdminHost'

// OS profiles.
param vm_osProfile_adminUsername string = 'satoadmin'
@secure()
param vm_osProfile_adminPassword string = newGuid()
param vm_osProfile_provisionVMAgent bool = true
param vm_osProfile_enableAutomaticUpdates bool = true
param vm_osProfile_patchMode string = 'AutomaticByPlatform'

// hardware profiles.
param vm_hardwareProfile_vmSize string = 'Standard_D4as_v5'

// security profiles.
param vm_securityProfile_securityType string = 'TrustedLaunch'
param vm_uefiSettings_secureBootEnabled bool = true
param vm_uefiSettings_vTpmEnabled bool = true

// storage profiles - OS disk.
param vm_osDisk_createOption string = 'FromImage'
param vm_osDisk_managedDisk_storageAccountType string = 'Premium_LRS'
param vm_osDisk_diskSizeGB int = 128

// storage profiles - image reference.
param vm_imageReference_publisher string = 'MicrosoftWindowsServer'
param vm_imageReference_offer string = 'WindowsServer'
param vm_imageReference_sku string = '2022-datacenter-azure-edition-hotpatch'
param vm_imageReference_version string = 'latest'

// diagnostics profiles.
param vm_diagnosticsProfile_bootDiagnostics_enabled bool = true // ブート診断 = マネージドストレージアカウントで有効にする

// additional capabilities.
param vm_additionalCapabilities_hibernationEnabled bool = true // 休止状態 = true

////////////////////////////////////////////////////////////
// AVD Session Host VM definition.
resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {

  // ** Required
  name: vm_name
  location: location

  tags: tags

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
	  hardwareProfile: {
	    vmSize: vm_hardwareProfile_vmSize
	  }
	  osProfile: {
	    computerName: vm_computerName
      windowsConfiguration: {
        provisionVMAgent: vm_osProfile_provisionVMAgent
        enableAutomaticUpdates: vm_osProfile_enableAutomaticUpdates
        patchSettings: {
          patchMode: vm_osProfile_patchMode
        }
      }
	    adminUsername: vm_osProfile_adminUsername
	    adminPassword: vm_osProfile_adminPassword
	  }
	  networkProfile: {
	    networkInterfaces: [
        {
		      id: avdSessionHostVmNic.id
		    }
      ]
	  }
    storageProfile: {
	    imageReference: {
        publisher: vm_imageReference_publisher
        offer: vm_imageReference_offer
        sku: vm_imageReference_sku
        version: vm_imageReference_version
      }
	    osDisk: {
		    createOption: vm_osDisk_createOption
		    managedDisk: {
		      storageAccountType: vm_osDisk_managedDisk_storageAccountType
		    }
		    diskSizeGB: vm_osDisk_diskSizeGB
	    }
	  }
    securityProfile: {
        securityType: vm_securityProfile_securityType
        uefiSettings: {
            secureBootEnabled: vm_uefiSettings_secureBootEnabled
            vTpmEnabled: vm_uefiSettings_vTpmEnabled
        }
    }
	  diagnosticsProfile: {
	    bootDiagnostics: {
		    enabled: vm_diagnosticsProfile_bootDiagnostics_enabled
		    storageUri: null // マネージドストレージアカウントを使用
	    }
	  }
	  additionalCapabilities: {
	    hibernationEnabled: vm_additionalCapabilities_hibernationEnabled
	  }
  }
}

resource shutdownschedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vm_name}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '23:00'
    }
    timeZoneId: 'Tokyo Standard Time'
    targetResourceId: vm.id
  }
}

output vm object = vm
