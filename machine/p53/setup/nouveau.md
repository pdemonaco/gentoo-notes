
# Configuration process

1. Ensure the nouveau module is configured in the kernel. Here's the flags as of 5.10.19

    ```kernel
    CONFIG_DRM_NOUVEAU=m
    # CONFIG_NOUVEAU_LEGACY_CTX_SUPPORT is not set
    CONFIG_NOUVEAU_DEBUG=5
    CONFIG_NOUVEAU_DEBUG_DEFAULT=3
    # CONFIG_NOUVEAU_DEBUG_MMU is not set
    # CONFIG_NOUVEAU_DEBUG_PUSH is not set
    CONFIG_DRM_NOUVEAU_BACKLIGHT=y
    # CONFIG_DRM_NOUVEAU_SVM is not set
    ```
1. Configure the video card setting in `/etc/portage/make.conf`.

    ```ini
    VIDEO_CARDS="nouveau intel"
    ```
1. Rebuild pulling in the necessary stuff.
1. Backup `/lib/udev/rules.d/99-nvidia.rules` somewhere so it can be avoided.

    ```bash
    mv /lib/udev/rules.d/99-nvidia.rules /lib/udev/rules.d/99-nvidia.bak
    ```
1. Make sure the nouveau module isn't blacklisted in `/etc/modprobe.d/blacklist`

    ```ini
    # If present, it should be commented out
    #blacklist nouveau
    ```
1. Hide the nvidia X11 config file

    ```bash
    git mv /etc/X11/xorg.conf.d/20-nvidia.conf /etc/X11/xorg.conf.d/20-nvidia.bak
    ```
1. Ensure no weird stuff about nvidia drivers is being passed to the kernel command line in `/etc/default/grub`.

    ```bash
    #GRUB_CMDLINE_LINUX_DEFAULT="snd-hda-intel.index=1,0 zfs_force=1 rd.vconsole.keymap=dvorak video=efifb nvidia-drm.modeset=1
    GRUB_CMDLINE_LINUX_DEFAULT="snd-hda-intel.index=1,0 zfs_force=1 rd.vconsole.keymap=dvorak video=efifb"
    ```
1. Do not add nvidia drivers to the initramfs (dracut in this case, done via `/etc/dracut.d/drivers.conf`).

    ```bash
    add_drivers+="nouveau"
    ```
1. TODO - Ensure the firmware for our card is loaded in the initramfs via `/etc/dracut.d/
1. TODO - something with this maybe? Capture monitor EDID data

    ```bash
    modprobe i2c-dev
    ```
1. Ensure X server actually deals with the monitors not attached to the NVIDIA card. Done in `~/.xinitrc`

    ```bash
    #xrandr --setprovideroutputsource modesetting NVIDIA-0
    xrandr --setprovideroutputsource nouveau Intel
    xrandr --auto
    ```

# Other Notes

## NOVEAU Firmware setting

This system has a Quadro T1000 (TU117) card. Apparently this is the same as the [NV167 (NV160)](https://nouveau.freedesktop.org/CodeNames.html) Turing family firmware.

Unclear whether this needs to be loaded into the kernel explicitly

## NVIDIA Driver Install

* [Lenovo X1 Guide](https://wiki.gentoo.org/wiki/Lenovo_ThinkPad_X1_Extreme)
* [Nouveau Optimus](https://nouveau.freedesktop.org/Optimus.html)
* [Nouveau Gentoo Wiki](https://wiki.gentoo.org/wiki/Nouveau)
* [Weird Interal Display Bug](https://bugzilla.redhat.com/show_bug.cgi?id=1896904)
