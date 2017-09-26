1. Install the microcode firmware files and the utility to edit them.

    ```bash
    emerge -avt sys-firmware/intel-microcode sys-apps/iucode_tool
    ```
2. Add `/etc/grub.d/10_linux` to your etc git repo
    
    ```bash
    cd /etc
    git add grub.d/10_linux
    git ci -m intel_microcode-pre-update
    ```

3. Modify `/etc/grub.d/10_linux` adding the following to the `initrd=` section.

    ```bash
    if test -e "{dirname}/${i}" ; then
      initrd="early_ucode.cpio ${rel_dirname}/${i}"
      break
    else
      initrd="early_ucode.cpio"
    fi
    ```
4. Store those changes to git if you do that.
5. Mount boot and generate a microcode file to load in.

    ```bash
    mount /boot
    iucode_tool -S --write-earlyfw=/boot/early_ucode.cpio /lib/firmware/intel-ucode/*
    ```
6. Regenerate your grub config file in the normal way.

    ```bash
    mv "/boot/grub/grub.cfg" "/boot/grub/grub.old"
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
