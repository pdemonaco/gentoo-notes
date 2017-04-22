You'll need to have a working local tftp server for this to work. The readme in the `../setup/tftp/` folder within this repo covers how to get this going properly on Gentoo.

# Catalyst 3560G 

1. Connect to the switch via the console port. Ideally, use a USB-to-serial adapter.

    ```bash
    screen /dev/ttyUSB0 9600,cs8,-parenb,-cstopb
    ```
2. Start a tftp server which has a mount point at `/tftp/`
3. Copy the switch image file to `/tftp` and change mod to 777 and ownership to nobody:root.
4. Perform a safe download of the specified files.

    ```bash
    archive download-sw /safe tftp://<ip>/<image-file>
    ```
    *Note that you do not need to specify `/tftp/` as it is the root of the mount*

This document primarily references upgrading to IOS 12.2(55)SE. Release notes can be found [here](http://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst3750/software/release/12-2_55_se/release/notes/OL23054.html#21027)

Another upgrade approach is detailed [here](https://www.packet6.com/how-to-upgrade-the-ios-of-a-cisco-switch/).

# Helpful Notes

* [Information about screen](http://www.noah.org/wiki/Screen_notes)
* [Connecting with putty](http://www.omnisecu.com/cisco-certified-network-associate-ccna/how-to-use-putty-to-configure-or-monitor-a-cisco-router-or-switch.php)
