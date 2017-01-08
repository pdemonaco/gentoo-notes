# Preparation

## Download Image and Setup the Kernel

1. Log into the Xen host and download the latest version of Alpine for Xen. 

    ```bash
    ssh odin.demona.co
    sudo -i
    cd /xen/image/
    wget https://fr.alpinelinux.org/alpine/v3.5/releases/x86_64/alpine-xen-3.5.0-x86_64.iso
    ```

    Note that the latest version may be located [here](https://www.alpinelinux.org/downloads/)
2. Mount the image somewhere temporarily to extract the kernel and initramfs.

    ```bash
    VERSION=alpine-xen-3.5.0-x86_64
    ISO="/xen/image/${VERSION}.iso"
    MNT="/tmp/${VERSION}"
    BOOT="/xen/boot/${VERSION}/"

    mkdir -p "${MNT}"
    mount -t iso9660 -o loop "${ISO}" "${MNT}"

    mkdir -p "${BOOT}"
    cp "${MNT}/boot/vmlinuz-grsec" "${BOOT}"
    cp "${MNT}/boot/initramfs-grsec" "${BOOT}"
    umount "${MNT}"
    rmdir "${MNT}"
    ```

## Define the VM

1. Create a new disk for this VM to use as it's OS partition.

    ```bash
    ZVOL="xen-pl/XEN/vdisk/alpine-test"
    zfs create -V 8g "${ZVOL}"
    ```
2. Create the Xen config file and prepare it for boot. See [this article](https://wiki.alpinelinux.org/wiki/Create_Alpine_Linux_PV_DomU#Create_a_DomU_config_file_that_boots_the_ISO_image) for more detail.


