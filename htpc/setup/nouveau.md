# Kernel Setup

1. Ensure that the following are enabled in the kernel.

    Flag | Description
    -----|------------
    CONFIG_MODULES | Nvidia generates a module
    CONFIG_MTRR | Memory Type Range
    CONFIG_AGP | Needed for support of the card itself
    CONFIG_DRM_NOUVEAU | Module support for the actual card
    CONFIG_FB_NVIDIA | I think we can have framebuffer support as well
2. Verify that the following are disabled.

    Flag             | Description
    -----------------|------------
    CONFIG_FB_NVIDIA | This driver supports graphics boards with the nVidia chips
    CONFIG_FB_RIVA   | This driver supports graphics boards with the nVidia Riva/Geforce
    CONFIG_FP_EFI    | This is the EFI frame buffer device driver
3. Compile the new kernel version and install it.

    ```bash
    KERNEL_VERSION="4.9.16-gentoo"
    make -j5 && make -j5 modules_install
    cp .config "/etc/kernels/kernel-config-${KERNEL_VERSION}-03"
    cd /etc/
    git add "/etc/kernels/kernel-config-${KERNEL_VERSION}-03"
    ```
4. Update `/etc/portage/make.conf` to set the appropriate graphics driver. 

    ```bash
    cd /etc
    sed -r 's/^(VIDEO_CARDS="[[:alnum:]_ ]+)/\1 nouveau/' /etc/portage/make.conf
    git add /etc/portage/make.conf
    emerge -avtuDNn world
    ```
5. Add the new driver to the autoload list

    ```bash
    cd /etc
    sed -i -r 's/^(modules="[[:alnum:]_ ]+)/\1 nouveau/' "/etc/conf.d/modules"
    git add "/etc/conf.d/modules"
    ```
6. Mount the boot volume and put the new kernel version out there.

    ```bash
    mount /boot
    cd /boot
    cp "/usr/src/linux/arch/x86_64/boot/bzImage" "/boot/kernel-${KERNEL_VERSION}-03"
    dracut --xz --kver "${KERNEL_VERSION}" "initramfs-${KERNEL_VERSION}-03.img" -f
    grub-mkconfig -o /boot/grub/grub.cfg
    ```


See the [gentoo wiki](https://wiki.gentoo.org/wiki/Nouveau) for more details.
