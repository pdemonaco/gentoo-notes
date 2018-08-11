# Upgrade Procedure

1. Select the new kernel version.

    ```bash
    eselect kernel list 
    eselect kernel set <number>
    ```
2. Make the appropriate modifications. If this is a minor build, i.e. `4.4.49` to `4.4.52` you don't need to get to crazy and can just copy in the old config.

    ```bash
    # Minor bump
    cd /usr/src/linux
    zcat /proc/config.gz > /usr/src/linux/.config
    make olddefconfig
    ```
3. Once the new kernel is ready to go copy the config to `/etc/kernels` and record it in git.

    ```bash
    KERNEL_VERSION="4.9.76-gentoo-r1"
    BUILD=00
    cp "/usr/src/linux/.config" "/etc/kernels/kernel-config-${KERNEL_VERSION}-${BUILD}"
    cd /etc/
    git add "/etc/kernels/kernel-config-${KERNEL_VERSION}-${BUILD}"
    cd -
    ```
4. Make the new kernel image.

    ```bash
    cd /usr/src/linux
    JOBS=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
    JOBS=$((JOBS + 1 ))
    make "-j${JOBS}" && make "-j${JOBS}" modules_install
    ```
5. Rebuild any necessary modules.

    ```bash
    emerge -avt @module-rebuild
    ```
5. Ensure `/boot` is mounted and copy in the new image.

    ```bash
    mount /boot
    cp "/usr/src/linux/arch/x86_64/boot/bzImage" \
        "/boot/kernel-${KERNEL_VERSION}-${BUILD}"
    ```
6. Generate our new initramfs file.

    ```bash
    dracut --xz "/boot/initramfs-${KERNEL_VERSION}-${BUILD}.img" \
        "${KERNEL_VERSION}"
    ```
7. Build a new configuration file for grub.

    ```bash
    mv "/boot/grub/grub.cfg" "/boot/grub/grub.old"
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
8. Some machines require the following fix to correct the path to sys-pl.

    ```bash
    POOL=$(zfs list | awk '$5 ~ /^\/$/ { split( $1, name, "/" ); print name[1] }')
    echo $POOL
    sed -i "s/ZFS=\//ZFS=${POOL}\//g" "/boot/grub/grub.cfg"
    ```

# Remove old Kernel

1. Run the deep clean procedure.

    ```bash
    emerge -avc
    ```
2. Remove old files

    ```bash
    KERNEL_VERSION="4.4.52-gentoo"
    rm -r "/usr/src/linux-${KERNEL_VERSION}"
    rm -r "/lib/modules/${KERNEL_VERSION}"
    ```

# Additional Detail

* [Kernel Upgrade](https://wiki.gentoo.org/wiki/Kernel/Upgrade)
* [Kernel Removal](https://wiki.gentoo.org/wiki/Kernel/Removal)
