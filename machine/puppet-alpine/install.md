# OS Installation

## Prepare Image

1. Log into the Xen host and download the latest version of Alpine for Xen. 

    ```bash
    ssh odin.demona.co
    sudo -i
    cd /xen/image/
    wget http://dl-cdn.alpinelinux.org/alpine/v3.6/releases/x86_64/alpine-xen-3.6.2-x86_64.iso
    ```

    Note that the latest version may be located [here](https://www.alpinelinux.org/downloads/)
2. Mount the image somewhere temporarily to extract the kernel and initramfs.

    ```bash
    VERSION=alpine-xen-3.6.2-x86_64
    ISO="/xen/image/${VERSION}.iso"
    MNT="/tmp/${VERSION}"
    BOOT="/xen/boot/${VERSION}/"

    mkdir -p "${MNT}"
    mount -t iso9660 -o loop "${ISO}" "${MNT}"

    mkdir -p "${BOOT}"
    cp "${MNT}/boot/vmlinuz-hardened" "${BOOT}"
    cp "${MNT}/boot/initramfs-hardened" "${BOOT}"
    umount "${MNT}"
    rmdir "${MNT}"
    ```

## VM Definition

1. Create a new disk for this VM.

    ```bash
    ZVOL="xen-pl/XEN/vdisk/puppet00"
    zfs create -V 8g "${ZVOL}"
    ```
2. Create the Xen config file and prepare it to boot from CD. In this case [this](./puppet.pv)
3. Also generate a mac address and add it to the interface.

    ```bash
    xxd -p -l 6 /dev/urandom | awk '{ and_num = strtonum("0xfeffffffffff"); or_num = strtonum("0x020000000000"); numstr = "0x"$1; num = strtonum(numstr); mod_num = and( or( num, or_num ), and_num ); printf "%0x\n", mod_num; }'
    ```

## Install Alpine

1. Start the DomU.

    ```bash
    xl create -f /etc/xen/config/puppet00.pv -c
    ```
2. Log in as root, no password.
3. Begin the setup process for alpine

    ```bash
    setup-alpine
    Select keyboard layout [none]: us
    Select variant []: us
    Enter system hostname (short form, e.g. 'foo') [localhost]: puppet00
    Which one do you want to initialize? (or '?' or 'done') [eth0]
    Ip address for eth0? (or 'dhcp', 'none', '?') [dhcp] 172.24.28.11/24
    Gateway? (or 'none') [none] 172.24.28.1
    Do you want to do any manual network configuration? [no]
    DNS domain name? (e.g 'bar.com') [] demona.co
    DNS nameserver(s)? [] 172.24.132.7
    Which timezone are you in? ('?' for list) [UTC]
    HTTP/FTP proxy URL? (e.g. 'http://proxy:8080', or 'none') [none]
    Enter mirror number (1-21) or URL to add (or r/f/e/done) [f]: f
    Which SSH server? ('openssh', 'dropbear' or 'none') [openssh]
    Which NTP client to run? ('busybox', 'openntpd', 'chrony' or 'none') [chrony]
    Which disk(s) would you like to use? (or '?' for help or 'none') [none] xvda
    How would you like to use it? ('sys', 'data', 'lvm' or '?' for help) [?] sys
    WARNING: Erase the above disk(s) and continue? [y/N]: y
    ```
4. Mount the boot volume to create the grub config file.

    ```bash
    mount /dev/xvda3 /mnt
    mount /dev/xvda1 /mnt/boot
    ```
5. Comment out the ISO boot line from the config file as shown below:

    ```bash
    #extra="alpine_dev=xvdc:iso9660 modules=loop,squashfs,sd-mod,usb-storage console=hvc0"
    ```
6. Boot into the new environment and install grub.
    
    ```bash
    apk update
    apk add grub
    ```
7. Create the grub config directory and generate a local config file for pvgrub to utilize at the next boot.

    ```bash
    mount /boot
    mkdir -p /boot/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
8. Halt the system.
9. Update the config file to match [this](./puppet-pvgrub.pv) by removing the external kernel lines and specifying the pvgrub bootloader bundle.
10. Boot the system with the new config and login.
