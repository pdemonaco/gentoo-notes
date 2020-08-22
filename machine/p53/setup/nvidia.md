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
    GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1"
    ```
1. Add the nvidia modules to the initramfs.

    ```bash
    add_drivers+="nvidia nvidia_modeset nvidia_uvm"
    ```
1. Capture monitor EDID data

### Bumblebee stuff that didn't work

1. Disable `kms` and `uvm`.

    ```bash
    echo 'x11-drivers/nvidia-drivers -kms' >> '/etc/portage/package.use/nvidia'
    echo 'x11-drivers/nvidia-drivers -uvm' >> '/etc/portage/package.use/nvidia'
    ```
1. Ensure we have the `tools` flag for the intel video driver.

    ```bash
    echo "x11-drivers/xf86-video-intel tools" >> /etc/portage/package.use/nvidia
    ```
1. Install Nvidia's proprietary drivers. There's some weirdness about versions. PCI Device ID for this one is `10de 2183` and it echo ">=x11-drivers/nvidia-drivers-450.57-r1 NVIDIA-r2" >> /etc/portage/package.license/nvidiaworks with version 450.57-r1 which is the latest as of this writing.

    ```bash
    echo ">=x11-drivers/nvidia-drivers-450.57-r1 NVIDIA-r2" >> /etc/portage/package.license/nvidia
    emerge -avt x11-drivers/nvidia-drivers
    ```
1. Update the xserver device settings in `/etc/X11/xorg.conf.d/20-nvidia.conf`.

    ```bash
    Section "Device"
       Identifier  "nvidia"
       Driver      "nvidia"
    EndSection
    ```
1. Emerge bumblebee, bbswitch, and primus.

    ```bash
    echo "x11-misc/primus" >> /etc/portage/package.accept_keywords/nvidia
    emerge --ask sys-power/bbswitch x11-misc/bumblebee x11-misc/primus
    ```
1. Add self to the necessary groups.

    ```bash
    usermod -a -G video,bumblebee phil
    ```
1. Remove the dependencies for bumblebee from `/etc/init.d/bumblebee`
1. Update `/etc/bumblebee/bumblebee.conf`.
1. Add bumblebee to the default runlevel

    ```bash
    rc-update add bumblebee default
    ```

* [General Bumblebee Guide](https://wiki.gentoo.org/wiki/NVIDIA/Bumblebee)
* [Lenovo X1 Guide](https://wiki.gentoo.org/wiki/Lenovo_ThinkPad_X1_Extreme)
* [Nvidia Driver Config](https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers#Kernel)
* [Nvidia Driver Config - Arch](https://wiki.archlinux.org/index.php/NVIDIA)
