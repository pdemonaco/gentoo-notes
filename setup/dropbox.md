1. Create a zvol for the device.

    ```bash
    POOL="sys-pl"
    zfs create "${POOL}/HOME/phil-dropbox" -V 16G -b 4K
    mkfs.ext4 "/dev/${POOL}/HOME/phil-dropbox"
    ```
2. Add the drive to fstab.

    ```bash
    echo "/dev/${POOL}/HOME/phil-dropbox        /home/phil/dropbox  ext4  defaults    0 2" >> /etc/fstab
    ```

