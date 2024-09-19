using './main.bicep'

param tenantId = readEnvironmentVariable('AZURE_TENANT_ID', 'put-your-default-tenant-id-here')
param systemName = readEnvironmentVariable('SYSTEM_NAME', 'put-your-default-system-name-here')
param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'put-your-default-environment-name-here')
param location = readEnvironmentVariable('AZURE_LOCATION', 'put-your-default-location-here')

// for the security rule of the Azure Bastion
var clientIpAddressRange = readEnvironmentVariable('CLIENT_IP_ADDRESS_RANGE', '0.0.0.0')

////////////////////////////////////////////////////////////
// Parameters for the resource group.

// The name of the resource group, called as 'RagRg'.
param rg_name = readEnvironmentVariable('AZURE_RESOURCE_GROUP_NAME', '${systemName}-${environmentName}')

////////////////////////////////////////////////////////////
// Parameters for the NAT Gateway.
param natGw_name = '${systemName}-NatGw-${environmentName}'
param natGw_Ip_name = '${systemName}-NatGwIP-${environmentName}'

////////////////////////////////////////////////////////////
// Parameters for the virtual network.

// The Rag main virtual network, called as 'RagVNet'.
param mainVNet_name = '${systemName}-MainVnet-${environmentName}'
param mainVNet_addressPrefix = '10.0.0.0/16'
param mainVNet_encryptionEnabled = true
param mainVNet_ddosProtectionEnabled = false

// The management subnet, called as 'AdminSubnet'.
param adminSubnet_name = 'AdminSubnet'
param adminSubnet_addressPrefix = '10.0.0.0/29'
param adminSubnet_defaultOutboundAccess = false
param adminSubnet_privateEndpointNetworkPolicies = 'NetworkSecurityGroupEnabled'

// The bastion subnet, called as 'AzureBastionSubnet'.
param bastionSubnet_name = 'AzureBastionSubnet'
param bastionSubnet_addressPrefix = '10.0.0.64/26'
param bastionSubnet_defaultOutboundAccess = false
param bastionSubnet_privateEndpointNetworkPolicies = 'Disabled'

param gatewaySubnet_name = 'GatewaySubnet'
param gatewaySubnet_addressPrefix = '10.0.0.32/27'
param gatewaySubnet_defaultOutboundAccess = false
param gatewaySubnet_privateEndpointNetworkPolicies = 'Disabled'

////////////////////////////////////////////////////////////
// Parameters for the Virtural Machines.

// The Network intafacce card of the AdminVm.
param adminVm_nic_name = '${systemName}-AdminVmNic-${environmentName}'
param adminVm_nic_ipConfiguration_name = 'ipconfig1'
param adminVm_nic_ipConfiguration_privateIPAllocationMethod = 'Dynamic'

// The virtual machine used for the management, called as 'AdminVm'.
param adminVm_name = '${systemName}-AdminVm-${environmentName}'
param adminVm_computerName = 'AdminHost'
param adminVm_osProfile_adminUsername = 'satoadmin'
@secure()
param adminVm_osProfile_adminPassword = readEnvironmentVariable('ADMIN_VM_ADMIN_PASSWORD', 'put-your-default-admin-vm-admin-password-here')
param adminVm_osProfile_provisionVMAgent = true
param adminVm_osProfile_enableAutomaticUpdates = true
param adminVm_osProfile_patchMode = 'AutomaticByPlatform'

// The hardware profiles of the AdminVm.
param adminVm_hardwareProfile_vmSize = 'Standard_D4as_v5'

// The security profiles of the AdminVm.
param adminVm_securityProfile_securityType = 'TrustedLaunch'
param adminVm_uefiSettings_secureBootEnabled = true
param adminVm_uefiSettings_vTpmEnabled = true

// The storage profiles of the AdminVm - OS disk.
param adminVm_osDisk_createOption = 'FromImage'
param adminVm_osDisk_managedDisk_storageAccountType = 'Premium_LRS'
param adminVm_osDisk_diskSizeGB = 128

// The storage profiles of the AdminVm - image reference.
param adminVm_imageReference_publisher = 'MicrosoftWindowsServer'
param adminVm_imageReference_offer = 'WindowsServer'
param adminVm_imageReference_sku = '2022-datacenter-azure-edition'
param adminVm_imageReference_version = 'latest'

// The diagnostics profiles of the AdminVm.
param adminVm_diagnosticsProfile_bootDiagnostics_enabled = true

// The additional capabilities of the AdminVm.
param adminVm_additionalCapabilities_hibernationEnabled = false

////////////////////////////////////////////////////////////
// Parameters for the Azure Bastion.

// The public IP address for the Azure Bastion.
param bastion_ip_name = '${systemName}-BastionIP-${environmentName}'

// The Azure Bastion.
param bastion_name = '${systemName}-Bastion-${environmentName}'
param bastion_sku = 'Basic'

// The Network Security Group for the AzureBastionSubnet.
param bastionNsg_name = '${systemName}-BastionNsg-${environmentName}'

// Definitions of Outbound traffic rules.
param bastionNsg_securityRules_outBound = [
      {
        name: 'AllowSshRdpToVNet'
        properties: {
          description: 'Allow SSH and RDP to the Virtual Network.'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowHttpsToAzureCloud'
        properties: {
          description: 'Allow HTTPS to Azure Cloud.'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowSessionInformationToInternet'
        properties: {
          description: 'Allow Session Information with HTTP to Internet.'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastioinCommunicationAmoungVNet'
        properties: {
          description: 'Allow Bastion Communication among the Virtual Network.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          description: 'Deny All Outbound Traffic.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Outbound'
        }
      }
    ]

// Definitions of Inbound traffic rules.
param bastionNsg_securityRules_inBound = [
      {
        name: 'AllowFromGatewayManager'
        properties: {
          description: 'Allow Gateway Manager.'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowFromAzureLoadBalancer'
        properties: {
          description: 'Allow Azure Load Balancer.'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationAmoungVNet'
        properties: {
          description: 'Allow Bastion Host Communication among the Virtual Network.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowClientIpToAccessToBastion'
        properties: {
          description: 'Allow Client IP to access to bastion.'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: clientIpAddressRange
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 210
          direction: 'Inbound'
        }
      } 
      {
        name: 'DenyAllInbound'
        properties: {
          description: 'Deny All Inbound Traffic.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      } 
    ]

////////////////////////////////////////////////////////////
// Parameters for the P2S VPN Gateway.

param vpnGateway_name = '${systemName}-P2SVpnGw-${environmentName}'
param vpnGateway_gatewayType = 'Vpn'
param vpnGateway_sku  = 'VpnGw1'
param vpnGateway_generation  = 'Generation1'
param vpnGateway_ip1_name = '${systemName}-P2SVpnGwIp1-${environmentName}'
param vpnGateway_ip2_name = '${systemName}-P2SVpnGwIp2-${environmentName}'
param vpnGateway_configureBgp = false
param vpnGateway_addressPool = '192.168.10.0/24'
param vpnGateway_tunnelType = 'OpenVPN'
param vpnGateway_authenticationType = 'AAD'
param vpnGateway_userVpnPublicIpName = '${systemName}-P2SVpnGwIpEntryPoint-${environmentName}'
