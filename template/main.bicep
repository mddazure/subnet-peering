param rgName string = 'subnet-peering-rg'
param location string = 'swedencentral'

param vnetleftName string = 'vnet-left'
param vnetleftRange1 string = '10.0.0.0/16'
param vnetleftRange2 string = '172.16.0.0/16'
param vnetleftSubnet0Name string = 'subnet0-left'
param vnetleftSubnet0Range string = '10.0.0.0/24'
param vnetleftSubnet1Name string = 'subnet1-left'
param vnetleftSubnet1Range string = '10.0.1.0/24'
param vnetleftSubnet2Name string = 'subnet2-left'
param vnetleftSubnet2Range string = '10.0.2.0/24'
param vnetleftSubnet3Name string = 'subnet3-left'
param vnetleftSubnet3Range string = '172.16.3.0/24'

param vnetrightName string = 'vnet-right'
param vnetrightRange1 string = '10.1.0.0/16'
param vnetrightRange2 string = '172.16.0.0/16'
param vnetrightSubnet0Name string = 'subnet0-right'
param vnetrightSubnet0Range string = '10.1.0.0/24'
param vnetrightSubnet1Name string = 'subnet1-right'
param vnetrightSubnet1Range string = '10.1.1.0/24'
param vnetrightSubnet2Name string = 'subnet2-right'
param vnetrightSubnet2Range string = '10.1.2.0/24'
param vnetrightSubnet3Name string = 'subnet3-right'
param vnetrightSubnet3Range string = '172.16.3.0/24'

param vmleft0Name string = 'vm0-left'
param vmleft1Name string = 'vm1-left'
param vmleft2Name string = 'vm2-left'
param vmleft3Name string = 'vm3-left'

param vmright0Name string = 'vm0-right'
param vmright1Name string = 'vm1-right'
param vmright2Name string = 'vm2-right'
param vmright3Name string = 'vm3-right'

param vmSize string = 'Standard_B1s'
param imagePublisher string = 'canonical'
param imageOffer string = 'ubuntu-24_04-lts'
param imageSku string = 'server'
param imageVersion string = 'latest'

param vmAdminUsername string = 'AzureAdmin' 
@secure()
param vmAdminPw string = 'S@bnet0!'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module vnetleft 'vnet.bicep' = {
  name: 'vnet-left'
  scope: rg
  params: {
    location: location
    vnetName: vnetleftName
    vnetRange1: vnetleftRange1
    vnetRange2: vnetleftRange2
    vnetSubnet0Name: vnetleftSubnet0Name
    vnetSubnet0Range: vnetleftSubnet0Range
    vnetSubnet1Name: vnetleftSubnet1Name
    vnetSubnet1Range: vnetleftSubnet1Range
    vnetSubnet2Name: vnetleftSubnet2Name
    vnetSubnet2Range: vnetleftSubnet2Range
    vnetSubnet3Name: vnetleftSubnet3Name
    vnetSubnet3Range: vnetleftSubnet3Range
  }
}
module vnetright 'vnet.bicep' = {
  name: 'vnet-right'
  scope: rg
  params: {
    location: location
    vnetName: vnetrightName
    vnetRange1: vnetrightRange1
    vnetRange2: vnetrightRange2
    vnetSubnet0Name: vnetrightSubnet0Name
    vnetSubnet0Range: vnetrightSubnet0Range
    vnetSubnet1Name: vnetrightSubnet1Name
    vnetSubnet1Range: vnetrightSubnet1Range
    vnetSubnet2Name: vnetrightSubnet2Name
    vnetSubnet2Range: vnetrightSubnet2Range
    vnetSubnet3Name: vnetrightSubnet3Name
    vnetSubnet3Range: vnetrightSubnet3Range
  }
}

module vmleft0 'vm.bicep' = {
  name: 'vm0-left'
  scope: rg
  params: {
    location: location
    vmName: vmleft0Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetleft.outputs.vnetId
    subnetId: vnetleft.outputs.subnet0Id
  }
}
module vmleft1 'vm.bicep' = {
  name: 'vm1-left'
  scope: rg
  params: {
    location: location
    vmName: vmleft1Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetleft.outputs.vnetId
    subnetId: vnetleft.outputs.subnet1Id
  }
}
module vmleft2 'vm.bicep' = {
  name: 'vm2-left'
  scope: rg
  params: {
    location: location
    vmName: vmleft2Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetleft.outputs.vnetId
    subnetId: vnetleft.outputs.subnet2Id
  }
}
module vmleft3 'vm.bicep' = {
  name: 'vm3-left'
  scope: rg
  params: {
    location: location
    vmName: vmleft3Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetleft.outputs.vnetId
    subnetId: vnetleft.outputs.subnet3Id
  }
}
module vmright0 'vm.bicep' = {
  name: 'vm0-right'
  scope: rg
  params: {
    location: location
    vmName: vmright0Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetright.outputs.vnetId
    subnetId: vnetright.outputs.subnet0Id
  }
}
module vmright1 'vm.bicep' = {
  name: 'vm1-right'
  scope: rg
  params: {
    location: location
    vmName: vmright1Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetright.outputs.vnetId
    subnetId: vnetright.outputs.subnet1Id
  }
}
module vmright2 'vm.bicep' = {
  name: 'vm2-right'
  scope: rg
  params: {
    location: location
    vmName: vmright2Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetright.outputs.vnetId
    subnetId: vnetright.outputs.subnet2Id
  }
}
module vmright3 'vm.bicep' = {
  name: 'vm3-right'
  scope: rg
  params: {
    location: location
    vmName: vmright3Name
    vmSize: vmSize
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    imageVersion: imageVersion
    vmAdminUsername: vmAdminUsername
    vmAdminPw: vmAdminPw
    vnetId: vnetright.outputs.vnetId
    subnetId: vnetright.outputs.subnet3Id
  }
}
/*module peering 'peering.bicep' = {
  name: 'vnet-peering'
  scope: rg
  params: {
    vnetleftId: vnetleft.outputs.vnetId
    vnetrightId: vnetright.outputs.vnetId
    vnetleftName: vnetleftName
    vnetrightName: vnetrightName
    vnetleftsubnet0Id: vnetleft.outputs.subnet0Id
    vnetleftsubnet1Id: vnetleft.outputs.subnet1Id
    vnetleftsubnet2Id: vnetleft.outputs.subnet2Id
    vnetleftsubnet3Id: vnetleft.outputs.subnet3Id
    vnetrightsubnet0Id: vnetright.outputs.subnet0Id
    vnetrightsubnet1Id: vnetright.outputs.subnet1Id
    vnetrightsubnet2Id: vnetright.outputs.subnet2Id 
    vnetrightsubnet3Id: vnetright.outputs.subnet3Id
  }
}*/

