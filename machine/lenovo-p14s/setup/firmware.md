## Firmware Update Utility

1. Set some use flags which seem correct in `/etc/portage/package.use/fwupd`

    ```bash
    sys-apps/fwupd agent
    sys-apps/fwupd amt
    sys-apps/fwupd nvme
    sys-apps/fwupd pkcs7
    # I think this is needed for the lenovo touchpad
    sys-apps/fwupd synaptics
    sys-apps/fwupd thunderbolt
    sys-apps/fwupd tpm
    sys-apps/fwupd uefi
    ```
1. Install the firmware update utility

    ```bash
    emerge -avt sys-apps/fwupd
    ```
1. Add it to the default runlevel and start that bitch up.

    ```bash
    rc-update add fwupd default
    rc-service fwupd start
    ```
