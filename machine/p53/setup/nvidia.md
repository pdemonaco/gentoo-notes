## NVIDIA Driver Install

1. Ensure nouveau is disabled in the kernel and some other settings.

    ```bash
    CONFIG_DRM_NOUVEAU=N
    CONFIG_I2C_NVIDIA_GPU=N
    CONFIG_X86_SYSFB=Y
    ```
1. Set `VIDEO_CARDS="nvidia"` in `/etc/portage/make.conf`
1. Update `/etc/X11/xorg.conf.d/20-nvidia.conf` to the following:

    ```bash
    Section "ServerLayout"
        Identifier "layout"
        Screen 0 "nvidia"
        Inactive "intel"
    EndSection

    Section "Device"
        Identifier "nvidia"
        Driver "nvidia"
        BusID "01:00:0"
        Option "RegistryDwords" "EnableBrightnessControl=1"
    EndSection

    Section "Screen"
        Identifier "nvidia"
        Device "nvidia"
        Option "AllowEmptyInitialConfiguration"
    EndSection

    Section "Device"
        Identifier "intel"
        Driver "modesetting"
    EndSection

    Section "Screen"
        Identifier "intel"
        Device "intel"
    EndSection
    ```
1. Set Direct Rendering Manager (DRM) via KMS as an additional kernel parameter in `/etc/default/grub`.

    ```bash
    GRUB_CMDLINE_LINUX_DEFAULT="video=efifb nvidia-drm.modeset=1"
    ```
1. Add the nvidia modules to the initramfs.

    ```bash
    add_drivers+="nvidia nvidia_modeset nvidia_uvm"
    ```
1. TODO - something with this maybe? Capture monitor EDID data

    ```bash
    modprobe i2c-dev
    ```
1. Ensure X server actually deals with the monitors not attached to the NVIDIA card. Done in `~/.xinitrc`

    ```bash
    xrandr --setprovideroutputsource modesetting NVIDIA-0
    xrandr --auto
    ```

* [Lenovo X1 Guide](https://wiki.gentoo.org/wiki/Lenovo_ThinkPad_X1_Extreme)
* [Nvidia Driver Config](https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers#Kernel)
* [Nvidia Optimus](https://wiki.gentoo.org/wiki/NVIDIA/Optimus#OpenRC)
* [Nvidia Driver Config - Arch](https://wiki.archlinux.org/index.php/NVIDIA)
* [Nvidia xrandr 1.4 guide](http://us.download.nvidia.com/XFree86/Linux-x86_64/450.57/README/randr14.html)
