# Subnet Peering

## The Basics: VNET Peering

Virtual Networks in Azure can be connected thorugh [VNET Peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview). Peered VNETs become one routing domain, meaning that the entire IP space of each VNET is visible to and reachable from the other VNET. This is great for many applications: wire speed connectivity without gateways or other complexitiies.

In this diagram, vnet-left and vnet-right are peered: 

![images](/images/vnet-peering.png)

This is what that looks like in the portal for `vnet-left` (with the righthand vnet similar):

![images](/images/full-peering-left.png)

Effective routes of vm's in either vnet show the entire ip space of the peered vnet.

For vm `left-1` in `vnet-left`:

```
az network nic show-effective-route-table -g sn-rg -n left-1701 -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.0.0.0/16       VnetLocal
Default   Active   10.1.0.0/16       VNetPeering
Default   Active   0.0.0.0/0         Internet
```

And for vm `right-1` in `vnet-right`:

```
az network nic show-effective-route-table -g sn-rg -n right-159 -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.1.0.0/16       VnetLocal
Default   Active   10.0.0.0/16       VNetPeering
Default   Active   0.0.0.0/0         Internet
```

## The Problem
There are situations where completely merging the address spaces of VNETs is not desirable. 

Think of micro-segmentation: only the front-end of a multi-tier application must be exposed and accessible from outside the VNET, with the application- and database tiers ideally remaining isolated. Network Security Groups are now used to achieve isolation; they can block access to the internal tiers from sources outside of the vnet's ip range, or the front-end subnet.

Another scenario is IP address space exhaustion: private ip space is a scarce resource in many companies. There may not be enough free space available to assign each vnet a unique, routable, segment large enough to accomodate all resources hosted in each vnet. Again, there may not be a need for all resources to have a routable ip address as they do not need to be accessible from outside the vnet.

## The Solution: Subnet Peering
The above scenario's could be solved for if it were possible to selectively share a vnet's address range across a peering. 

Enter [Subnet Peering](https://learn.microsoft.com/en-us/azure/virtual-network/how-to-configure-subnet-peering): this new capability allows selective sharing of IP address space across a peering at the subnet level. 

Subnet Peering is not yet available through the Azure portal, but can be configured through the Azure CLI. A few new parameters have been added to the existing `az network vnet peering create` command:

- `--peer-complete-vnets {0, 1 (default), f, false, n, no, t, true, y, yes}`: when set to 0, false or no configures peering at the subnet level in stead of at the vnet level.
- `--local-subnet-names`: list of subnets to be peered in the current vnet (i.e. the vnet called out in the `--vnet-name` parameter)
- `--remote-vnet-names`: list of subnets to be peered in the remote vnet (i.e. the vnet called out in the `--remote-vnet` parameter)
- `--enable-only-ipv6 {0(default), 1, f, false, n, no, t, true, y, yes}`: if set to true, peers only ipv6 space in dual stack vnets.

:exclamation: Although Subnet Peering is available in all Azure regions, subscription allow-listing through this [form](https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbR4Qnh_A4SJlJmB_ayXa7POFUNzlOVDdXQlY5WUxHWkcyNTZPRFpQV01VUi4u&route=shorturl) is still required. Please read and be aware of the caveats under point 11 on the form.

### Segmentation

This command peers `subnet1` in `vnet-left` to `subnet0` and `subnet2` in `right-vnet`:

```
az network vnet peering create -g sn-rg -n left0-right0 --vnet-name vnet-left --local-subnet-names subnet1 --remote-subnet-names subnet0 subnet2 --remote-vne vnet-right --peer-complete-vnets 0 --allow-vnet-access 1
```

Then establish the peering in the other direction:

```
az network vnet peering create -g sn-rg -n right0-left0 --vnet-name vnet-right --local-subnet-names subnet0 subnet2 --remote-subnet-names subnet1 --remote-vne vnet-left --peer-complete-vnets 0 --allow-vnet-access 1
```

This leaves `subnet0` and `subnet2` in `vnet-left`, and `subnet1` in `vnet-right` disconnected, effectively creating segmentation between the peered vnets without the use of NSGs.

Details of the peerings in both directions are below. Notice the localAddressSpace and remoteAddressSpace prefixes are those of the peered local and remote subnets.

```
az network vnet peering show -g sn-rg -n left0-right0 --vnet-name vnet-left
```

```json       
{
  "allowForwardedTraffic": false,
  "allowGatewayTransit": false,
  "allowVirtualNetworkAccess": true,
  "doNotVerifyRemoteGateways": false,
  "etag": "W/\"6a80a7da-36f4-404c-8bd8-d23e1b2bdd9a\"",
  "id": "/subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-left/virtualNetworkPeerings/left0-right0",
  "localAddressSpace": {
    "addressPrefixes": [
      "10.0.1.0/24"
    ]
  },
  "localSubnetNames": [
    "subnet1"
  ],
  "localVirtualNetworkAddressSpace": {
    "addressPrefixes": [
      "10.0.1.0/24"
    ]
  },
  "name": "left0-right0",
  "peerCompleteVnets": false,
  "peeringState": "Connected",
  "peeringSyncLevel": "FullyInSync",
  "provisioningState": "Succeeded",
  "remoteAddressSpace": {
    "addressPrefixes": [
      "10.1.0.0/24",
      "10.1.2.0/24"
    ]
  },
  "remoteSubnetNames": [
    "subnet0",
    "subnet2"
  ],
  "remoteVirtualNetwork": {
    "id": "/subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-right",
    "resourceGroup": "sn-rg"
  },
  "remoteVirtualNetworkAddressSpace": {
    "addressPrefixes": [
      "10.1.0.0/24",
      "10.1.2.0/24"
    ]
  },
  "remoteVirtualNetworkEncryption": {
    "enabled": false,
    "enforcement": "AllowUnencrypted"
  },
  "resourceGroup": "sn-rg",
  "resourceGuid": "eb63ec9e-aa48-023e-1514-152f8ab39ae7",
  "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
  "useRemoteGateways": false
```
`az network vnet peering show -g sn-rg -n right0-left0 --vnet-name vnet-right `
```json
{
  "allowForwardedTraffic": false,
  "allowGatewayTransit": false,
  "allowVirtualNetworkAccess": true,
  "doNotVerifyRemoteGateways": false,
  "etag": "W/\"bd0f0486-e84e-4dae-9a35-c8126e935cde\"",
  "id": "/subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-right/virtualNetworkPeerings/right0-left0",
  "localAddressSpace": {
    "addressPrefixes": [
      "10.1.0.0/24",
      "10.1.2.0/24"
    ]
  },
  "localSubnetNames": [
    "subnet0",
    "subnet2"
  ],
  "localVirtualNetworkAddressSpace": {
    "addressPrefixes": [
      "10.1.0.0/24",
      "10.1.2.0/24"
    ]
  },
  "name": "right0-left0",
  "peerCompleteVnets": false,
  "peeringState": "Connected",
  "peeringSyncLevel": "FullyInSync",
  "provisioningState": "Succeeded",
  "remoteAddressSpace": {
    "addressPrefixes": [
      "10.0.1.0/24"
    ]
  },
  "remoteSubnetNames": [
    "subnet1"
  ],
  "remoteVirtualNetwork": {
    "id": "/subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-left",
    "resourceGroup": "sn-rg"
  },
  "remoteVirtualNetworkAddressSpace": {
    "addressPrefixes": [
      "10.0.1.0/24"
    ]
  },
  "remoteVirtualNetworkEncryption": {
    "enabled": false,
    "enforcement": "AllowUnencrypted"
  },
  "resourceGroup": "sn-rg",
  "resourceGuid": "eb63ec9e-aa48-023e-1514-152f8ab39ae7",
  "type": "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
  "useRemoteGateways": false
}
```
The peerings show in the portal as "normal" vnet peerings, as subnet peering is not yet supported by the portal. 

![images](/images/subnet-peering-left.png)

The only indication that this is *not* a full vnet peering, is the peered IP address space - this is the subnet IP range of the remote subnet(s)

![images](/images/subnet-peering-left-ip-space.png)


Inspecting the effective routes on vm `left-1` shows it has routes for `subnet0` and `subnet2` but not for `subnet1` in `vnet-right`: 

```
az network nic show-effective-route-table -g sn-rg -n left-1701 -o table
```
```
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.0.0.0/16       VnetLocal
Default   Active   172.16.0.0/24     VnetLocal
Default   Active   10.1.0.0/24       VNetPeering
Default   Active   10.1.2.0/24       VNetPeering
Default   Active   0.0.0.0/0         Internet
```

Note that vm's `left-0` and `left-1` *also* have routes for the same subnets in `vnet-right`, even though their subnets were not listed in the `--local-subnet-names` parameter: 

```
az network nic show-effective-route-table -g sn-rg -n left-0681 -o table
```
```
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.0.0.0/16       VnetLocal
Default   Active   172.16.0.0/24     VnetLocal
Default   Active   10.1.0.0/24       VNetPeering
Default   Active   10.1.2.0/24       VNetPeering
Default   Active   0.0.0.0/0         Internet
```
```
az network nic show-effective-route-table -g sn-rg -n left-2809 -o table
```
```
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.0.0.0/16       VnetLocal
Default   Active   172.16.0.0/24     VnetLocal
Default   Active   10.1.0.0/24       VNetPeering
Default   Active   10.1.2.0/24       VNetPeering
Default   Active   0.0.0.0/0         Internet
```
In the current release, the ip space of the subnets listed in `--remote-subnet-names` is propagated to *all* subnets in the local vnet, not just to the subnets listed in `--local-subnet-names`.

However, the subnets in `vnet-right` only have the address space of `subnet1` in `vnet-left` propagated, as shows in the effective routes of the vm's on the right:
```
az network nic show-effective-route-table -g sn-rg -n right-0814 -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.1.0.0/16       VnetLocal
Default   Active   172.16.0.0/24     VnetLocal
Default   Active   10.0.1.0/24       VNetPeering
Default   Active   0.0.0.0/0         Internet

az network nic show-effective-route-table -g sn-rg -n right-159 -o table    
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.1.0.0/16       VnetLocal
Default   Active   172.16.0.0/24     VnetLocal
Default   Active   10.0.1.0/24       VNetPeering
Default   Active   0.0.0.0/0         Internet

az network nic show-effective-route-table -g sn-rg -n right-2283 -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.1.0.0/16       VnetLocal
Default   Active   172.16.0.0/24     VnetLocal
Default   Active   10.0.1.0/24       VNetPeering
Default   Active   0.0.0.0/0         Internet
```

Bidrectional routing therefore only exists between `subnet1` in `vnet-left` and `subnet0` and `subnet2` in `vnet-right`, as intended:

![images](/images/subnet-peering.png)

This is demonstrated by testing with ping from `left-1` to the vm's on the right:
```
to right-0:
PING 10.1.0.4 (10.1.0.4) 56(84) bytes of data.
64 bytes from 10.1.0.4: icmp_seq=1 ttl=64 time=1.20 ms
64 bytes from 10.1.0.4: icmp_seq=2 ttl=64 time=1.24 ms
64 bytes from 10.1.0.4: icmp_seq=3 ttl=64 time=1.06 ms
64 bytes from 10.1.0.4: icmp_seq=4 ttl=64 time=1.56 ms
^C
--- 10.1.0.4 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms

to right-1:
PING 10.1.1.4 (10.1.1.4) 56(84) bytes of data.
^C
--- 10.1.1.4 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4131ms

to right-2:
PING 10.1.2.4 (10.1.2.4) 56(84) bytes of data.
64 bytes from 10.1.2.4: icmp_seq=1 ttl=64 time=3.39 ms
64 bytes from 10.1.2.4: icmp_seq=2 ttl=64 time=0.968 ms
64 bytes from 10.1.2.4: icmp_seq=3 ttl=64 time=3.00 ms
64 bytes from 10.1.2.4: icmp_seq=4 ttl=64 time=2.47 ms
^C
--- 10.1.2.4 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
```
### Overlapping IP Space
Now let's add overlapping ip space to both vnets. 

With the peerings removed, we add 172.16.0.0/16 to each vnet, create `subnet3` with 172.16.3.0/24 and insert a vm.

When we try to peer the full vnets, an error results because of the address space overlap:
```
az network vnet peering create -g sn-rg -n left0-right0 --vnet-name vnet-left --remote-vnet vnet-right --peer-complete-vnets 1 --allow-vnet-access 1

(VnetAddressSpacesOverlap) Cannot create or update peering /subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-left/virtualNetworkPeerings/left0-right0. Virtual networks /subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-left and /subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-right cannot be peered because their address spaces overlap. Overlapping address prefixes: 172.16.0.0/16, 172.16.0.0/16
Code: VnetAddressSpacesOverlap
```
![images](/images/vnet-peering-overlap.png)

Now we will again establish the subnet-level peering as the previous section:

```
az network vnet peering create -g sn-rg -n left0-right0 --vnet-name vnet-left --local-subnet-names subnet1 --remote-subnet-names subnet0 subnet2 --remote-vne vnet-right --peer-complete-vnets 0 --allow-vnet-access 1
```

```
az network vnet peering create -g sn-rg -n right0-left0 --vnet-name vnet-right --local-subnet-names subnet0 subnet2 --remote-subnet-names subnet1 --remote-vne vnet-left --peer-complete-vnets 0 --allow-vnet-access 1
```

This completes successfully despite the presence of overlapping address space in both vnets.
```
az network vnet peering show -g sn-rg -n left0-right0 --vnet-name vnet-left --query  "[provisioningState, remoteAddressSpace]"
[
  "Succeeded",
  {
    "addressPrefixes": [
      "10.1.0.0/24",
      "10.1.2.0/24"
    ]
  }
]

az network vnet peering show -g sn-rg -n right0-left0 --vnet-name vnet-right --query  "[provisioningState, remoteAddressSpace]"
[
  "Succeeded",
  {
    "addressPrefixes": [
      "10.0.1.0/24"
    ]
  }
]
```
![images](/images/subnet-peering-overlap.png)

Now let's try to include `vnet-left` `subnet3`, which overlaps with `subnet3` on the right, in the peering:
```
az network vnet peering create -g sn-rg -n left0-right0 --vnet-name vnet-left --local-subnet-names subnet1 subnet3 --remote-subnet-names subnet0 subnet2 --remote-vne vnet-right --peer-complete-vnets 0 --allow-vnet-access 1

(VnetAddressSpacesOverlap) Cannot create or update peering /subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-left/virtualNetworkPeerings/left0-right0. Virtual networks /subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-left and /subscriptions/7cb39d93-f8a1-48a7-af6d-c8e12136f0ad/resourceGroups/sn-rg/providers/Microsoft.Network/virtualNetworks/vnet-right cannot be peered because their address spaces overlap. Overlapping address prefixes: 172.16.3.0/24
Code: VnetAddressSpacesOverlap
```
This demonstrates that subnet peering is allows for the partial peering of vnets that contain overlapping ip space. As discussed, this can be very helpful in scenario's where private ip space is in short supply.

# Looking ahead
Subnet peering is now available in all Azure regions: feel free to test, experiment and use in production.

The feature is currently only available through the latest versions of the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/network/vnet/peering?view=azure-cli-latest), [Bicep](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings?pivots=deployment-language-bicep), [ARM template](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings?pivots=deployment-language-bicep), [Terraform](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings?pivots=deployment-language-terraform) and Powershell.

Meaningful next steps will be to integrate Subnet Peering in both Azure Virtual Network Manager (AVNM) and Virtual WAN, so that the advantages it brings can be leveraged at enterpise scale in  nework foundations.

I will continue to track developments and update this post as appropriate.

