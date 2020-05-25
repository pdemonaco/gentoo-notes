## 1 - Partitioning

1. Begin partitioning the device

    ```bash
    DISK="/dev/sdb"
    parted -a optimal "${DISK}"
    ```
1. Within parted created a few normal block devices.

    ```bash
    unit mib
    mklabel gpt

    # Grub partition
    mkpart primary 1 3
    name 1 grub-0
    set 1 bios_grub on

    # kernel partition
    mkpart primary 3 513
    name 1 boot-0

    # Root VG partition
    mkpart primary 513 -1
    name 2 root
    toggle 2 lvm
    ```

## 2 - File systems

1. Install grub on the grub partition
1. Format the boot file system

    ```bash
    DISK="/dev/sdb"
    mkfs.ext2 -T small "${DISK}2"
    ```
1. Create the rootvg

    ```bash
    VG="rootvg"
    DISK="/dev/sdb"
    vgcreate "${VG}" "${DISK}3"
    ```
1. Create a swap LV

    ```bash
    # Create LV
    LV="lv_swap"
    lvcreate -L 2G -n "${LV}" "${VG}"

    # Make it swap
    mkswap "/dev/${VG}/${LV}"
    ```
1. Turn on the swap

    ```bash
    swapon "/dev/${VG}/${LV}"
    ```
1. Create the root LV and file system

    ```bash
    LV="lv_root"
    lvcreate -L 24G -n "${LV}" "${VG}"

    # Make it ext4
    mkfs.ext4 "/dev/${VG}/${LV}"
    ```

## 3 - Configure Services

1. Add LVM to boot

    ```bash
    rc-update add lvm boot
    ```
1. Install grub

    ```bash
    grub-install --target="i386-pc" "${DISK}"
    ```
