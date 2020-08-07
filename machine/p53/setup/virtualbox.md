
Create filesystem for virtual disks

```bash
POOL="sys-pl"
zfs create -o mountpoint=none "${POOL}/VBOX"
zfs create -o mountpoint=/home/phil/.VirtualBox/Machines -o compression=lz4 \
  "${POOL}/VBOX/phil-machines"
```
