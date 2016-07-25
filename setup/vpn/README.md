# OpenVPN Configuration

Walks through the configuration process for my internal VPN.

## Router Config

This was done on a Cisco SG300-20 in router mode.

1. Create the VLAN.

```cisco
vlan database
    vlan 78
```

2. Configure a global DHCP relay.

```cisco
ip dhcp relay enable
ip dhcp relay address 172.24.132.3
```

3. Configure the interface vlan

```cisco
int vlan 78
    name vpn
    ip address 172.24.68.1 /24
    ip dhcp relay enable
```

4. Trunk the VPN adapter down to the pfsense gateway

int gi16
    switchport trunk allowed vlan add 78

## DHCP Config

Modify `/etc/dhcp/config` to add the new vlan scope
