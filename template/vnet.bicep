param location string
param vnetName string 
param vnetRange1 string
param vnetRange2 string
param vnetSubnet0Name string 
param vnetSubnet0Range string
param vnetSubnet1Name string 
param vnetSubnet1Range string
param vnetSubnet2Name string 
param vnetSubnet2Range string
param vnetSubnet3Name string 
param vnetSubnet3Range string 

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetRange1
        vnetRange2
      ]
    }
    subnets: [
      {
        name: vnetSubnet0Name
        properties: {
          addressPrefix: vnetSubnet0Range
        }
      }
      {
        name: vnetSubnet1Name
        properties: {
          addressPrefix: vnetSubnet1Range
        }
      }
      {
        name: vnetSubnet2Name
        properties: {
          addressPrefix: vnetSubnet2Range
        }
      }
      {
        name: vnetSubnet3Name
        properties: {
          addressPrefix: vnetSubnet3Range
        }
      }
    ]
  }
}
output vnetId string = vnet.id
output subnet0Id string = vnet.properties.subnets[0].id
output subnet1Id string = vnet.properties.subnets[1].id
output subnet2Id string = vnet.properties.subnets[2].id
output subnet3Id string = vnet.properties.subnets[3].id

