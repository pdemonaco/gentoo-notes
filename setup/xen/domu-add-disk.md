Simple set of instructions to add a disk to a domU.

1. Create a new zVOL for this desired disk. 

    ```bash
    SIZE="1g"
    NAME="xen-pl/XEN/vdisk/puppet01-config"
    zfs create -V "${SIZE}" "${NAME}"
    ```
2. Modify the existing domain via `xl` to attach the new block device.

    ```bash
    DOMAIN=puppet01
    xl block-attach "${DOMAIN}" 'format=raw, vdev=xvdb, access=w, target=/dev/zvol/xen-pl/XEN/vdisk/puppet01-config'
    ```
    ![Pre Attach](img/domu-add-disk_pre-attach.png)
    ![Post Attach](img/domu-add-disk_post-attach.png)
3. At this point the new device should be visible from within the guest.

    ![View via lsblk](img/domu-add-disk_lsblk.png)
