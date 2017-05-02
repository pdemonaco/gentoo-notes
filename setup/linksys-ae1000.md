# Kernel Configuration

1. Determine the name & type of the device via lsusb. Apparently this is a Ralink RT3572.

    ![AE1000 Highlighted](img/linksys-ae1000_lsusb.png)
2. This device requires some kernel changes. Specifically, the overall Ralink module via `CONFIG_RT2X00` and the specific subcomponent `CONFIG_RT2800USB` and more specific sub-module `CONFIG_RT2800USB_RT35XX`. We'll see how this goes. 

    ```bash
    KERNEL="4.9.16-gentoo"
    NUM="01"
    make -j5 && make -j5 modules_install
    cp .config "/etc/kernels/kernel-config-${KERNEL}-${NUM}"
    cd /etc/
    git add "/etc/kernels/kernel-config-${KERNEL}-${NUM}"
    git commit -m 'Support for AE1000'
    ```
    Install the update kernel:

    ```bash
    mount /boot
    cp /usr/src/linux/arch/x86_64/boot/bzImage "/boot/kernel-${KERNEL}-${NUM}"
    cd /boot
    dracut "initramfs-${KERNEL}-${NUM}.img" --xz --kver "${KERNEL}" -H
    grub-mkconfig -o grub/grub.cfg
    ```
4. Update the automatically loaded modules to include this new one.

    ```bash
    cd /etc
    sed -i -r 's/^(modules="[[:alnum:]_ ]+)/\1 rt2800usb/' conf.d/modules
    git add conf.d/modules
    git commit -m 'Automatically load the rt2800usb module at boot'
    ```


# Alternate
http://blog.dutchcoders.io/installing-linksys-ae1000/
http://topics.mediatek.com/en/downloads1/downloads/?sort=product
