# Emerge DHCP service
```zsh
emerge -av net-misc/dhcp net-misc/ntp
```

Specify the correct listening interfaces in `/etc/conf.d/dhcpd`
For example: `DHCPD_IFACE="eth1"`

## Configure the Daemon
```zsh
vim /etc/dhcp/dhcpd.conf
```

## Start the service and add it to default
```zsh
eselect rc start dhcpd
eselect rc add dhcpd default
```

## Configure secure updates
# HMAC - SHA256 
dnssec-keygen -a HMAC-SHA256 -b 256 -n USER DHCP_UPDATER
