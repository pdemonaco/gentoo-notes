## AMDGPU Configuration

1. Set `VIDEO_CARDS="amdgpu radeonsi"` in `/etc/portage/make.conf`
1. Update `/etc/X11/xorg.conf.d/20-amdgpu.conf` to the following:

    ```bash
    Section "Device"
        Identifier "AMD"
        Driver     "amdgpu"
        Option     "TearFree" "true"
    EndSection
    ```

* [AMDGPU Guide - ArchLinux](https://wiki.archlinux.org/title/AMDGPU#Xorg_configuration)
* [AMDGPU Guide - Gentoo](https://wiki.gentoo.org/wiki/AMDGPU)
