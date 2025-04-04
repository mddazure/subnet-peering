
param vnetleftsubnet0Id string
param vnetleftsubnet1Id string
param vnetleftsubnet2Id string
param vnetleftsubnet3Id string
param vnetrightsubnet0Id string
param vnetrightsubnet1Id string
param vnetrightsubnet2Id string 
param vnetrightsubnet3Id string
param vnetrightId string
param vnetleftId string
param vnetleftName string
param vnetrightName string

resource peeringleft  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: '${vnetleftName}/peering-left'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetrightId
    }
  }
}
resource peeringright 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: '${vnetrightName}/peering-right'
  dependsOn: [
    peeringleft
  ]
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetleftId
    }
  }
} 
