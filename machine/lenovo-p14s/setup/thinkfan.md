
1. Ensure `CONFIG_THINKPAD_ACPI=m` is enabled in the kernel.
1. Configure the `thinkpad_acpi` module to enable fan control in `/etc/modprobe.d/thinkpad.conf`.

    ```bash
    echo "options thinkpad_acpi fan_control=1" >> /etc/modprobe.d/thinkpad.conf
    ```
1. Prep to install the thinkfan daemon.

    ```bash
    echo "app-laptop/thinkfan ~amd64" >> /etc/portage/package.accept_keywords/thinkfan
    echo "app-laptop/thinkfan atasmart" >> /etc/portage/package.use/thinkfan
    emerge -avt app-laptop/thinkfan
    ```
1. Build a working [/etc/thinkfan.yaml](./thinkfan.yaml) - note that this was created using all sensors available on my machine in kernel 5.4.60. Additional sensors including those for the NVMe drives may be available in newer kernels.
1. Test it out with `thinkfan -n -b -5 -c /etc/thinkfan.yaml` and see how it does.
1. Start thinkfan.

    ```bash
    rc-service thinkfan start
    rc-update add thinkfan default
    ```

* [Thinkfan Gentoo Wiki](https://wiki.gentoo.org/wiki/Fan_speed_control/thinkfan)
