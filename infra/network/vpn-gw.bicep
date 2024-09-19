metadata description = 'Create a VPN Gateway by bicep template with some tags.'
targetScope = 'resourceGroup'

////////////////////////////////////////////////////////////
// Definitions of the VPN Gateway.

@description('The location of the resource group.')
param location string = resourceGroup().location

@description('The name of the VPN Gateway.')
param vpnGatewayName string

@description('The type of the gateway. For VPN Gateway, it should be "Vpn".')
param gatewayType string

@description('The SKU of the VPN Gateway.')
param sku string

@description('The generation of the VPN Gateway.')
param generation string

@description('The name of the virtual network.')
param virtualNetworkName string

@description('The name of the subnet within the virtual network.')
param subnetName string

@description('The name of the public IP address for the first VPN Gateway.')
param vpnIp1Name string

@description('The name of the public IP address for the second VPN Gateway.')
param vpnIp2Name string

@description('Whether to configure BGP (Border Gateway Protocol).')
param configureBgp bool

@description('The address pool for the VPN clients.')
param addressPool string

@description('The tunnel type for the VPN. For example, "OpenVPN".')
param tunnelType string 

@description('The authentication type for the VPN. For example, "AAD".')
param authenticationType string

@description('The name of the public IP address for the VPN entry point to access from user.')
param vpnEntryPointIpName string

@description('The tenant ID for Azure Active Directory authentication.')
param tenantId string

@description('The tags to be applied to the resources.')
param tags object

////////////////////////////////////////////////////////////
// References to the existing GatewaySubnet.
resource GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}

// Public IP アドレスのモジュールを再利用
module VpnIp1 './public-ip.bicep' = {
  name: 'VpnIp1'
  params: {
    name: vpnIp1Name
    tags: tags
  }
}

module VpnIp2 './public-ip.bicep' = {
  name: 'VpnIp2'
  params: {
    name: vpnIp2Name
    tags: tags
  }
}

module VpnEntryPointIp './public-ip.bicep' = {
  name: 'VpnEntryPointIp'
  params: {
    name: vpnEntryPointIpName
    tags: tags
  }
}

// Resource definition for the P2S VPN Gateway.
// Refer to : https://learn.microsoft.com/en-us/azure/templates/microsoft.network/vpngateways?pivots=deployment-language-bicep
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: vpnGatewayName
  location: location
  tags: tags

  properties: {
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: VpnIp1.outputs.publicIpId
          }
          subnet: {
            id: GatewaySubnet.id
          }
        }
      }
      {
        name: 'activeActive'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: VpnIp2.outputs.publicIpId
          }
          subnet: {
            id: GatewaySubnet.id
          }
        }
      }
      {
        name: 'entryPoint'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: VpnEntryPointIp.outputs.publicIpId
          }
          subnet: {
            id: GatewaySubnet.id
          }
        }
      }
    ]
    vpnType: 'RouteBased'
    enableBgp: configureBgp
    activeActive: true
    gatewayType: gatewayType
    sku: {
      name: sku
      tier: sku
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          addressPool
        ]
      }
      vpnClientProtocols: [
        tunnelType
      ]
      vpnAuthenticationTypes: [
        authenticationType
      ]
      aadTenant: '${environment().authentication.loginEndpoint}${tenantId}/'
      aadAudience: 'c632b3df-fb67-4d84-bdcf-b95ad541b5c8'
      aadIssuer: 'https://sts.windows.net/${tenantId}/'
    }
    customRoutes: {
      addressPrefixes: []
    }
    vpnGatewayGeneration: generation
  }
  dependsOn: [
    GatewaySubnet
  ]
}
