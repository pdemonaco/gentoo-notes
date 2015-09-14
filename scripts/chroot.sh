#!/bin/bash
if [[ $1 = "start" ]]
then  
  zpool import -f -o cachefile= -R /mnt/gentoo rpool
  mount -t proc proc /mnt/gentoo/proc/
  mount --rbind /dev /mnt/gentoo/dev
  mount --rbind /sys /mnt/gentoo/sys
elif [[ $1 = "stop" ]]
then
  umount -l /mnt/gentoo/proc /mnt/gentoo/dev /mnt/gentoo/sys
  zpool export rpool
fi
