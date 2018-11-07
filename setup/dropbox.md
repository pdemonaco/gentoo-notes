1. Create a zvol for the device.

    ```bash
    POOL="sys-pl"
    zfs create "${POOL}/HOME/phil-dropbox" -V 16G -b 4K
    mkfs.ext4 "/dev/${POOL}/HOME/phil-dropbox"
    ```
2. Prep the new mount-point.

    ```bash
    USER="phil"
    ZVOL="/dev/${POOL}/HOME/${USER}-dropbox"

    # as your user
    mkdir -p "/home/${USER}/.ext4/"
    # as root mount it
    sudo mount "${ZVOL}" "/home/${USER}/.ext4/"
    ```
3. Migrate the data.
4. Add the drive to fstab.

    ```bash
    USER="phil"
    ZVOL="/dev/${POOL}/HOME/${USER}-dropbox"
    echo "${ZVOL}        /home/${USER}/.ext4  ext4  defaults    0 2" >> /etc/fstab
    ```

