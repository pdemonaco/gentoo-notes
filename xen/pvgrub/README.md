GRUB2 Xen PV Host Config
========================

Largely taken from this excellent blog post: https://blog.xenproject.org/2015/01/07/using-grub-2-as-a-bootloader-for-xen-pv-guests/

1. Make a working directory to prepare your bootloader files

```
mkdir /tmp/pvgrub
cd /tmp/pvgrub
```
2. Download grub.cfg and grub-bootstrap.cfg

3. Create the "memdisk" which is really just a tar of the grub.cfg file

```
tar cf memdisk.tar grub.cfg
```

4. Build the new image with grub-mkimage

```
grub2-mkimage -O x86_64-xen -c grub-bootstrap.cfg -m memdisk.tar -o grub-x86-64-xen.bin /usr/lib/grub/x86_64-xen/*.mod
```

5. Now you can manage your PV guest grub.cfg as if it were a standalone machine by replacing the "kernel" directive in your config file with something similar to the following
```
kernel = "/mnt/xen/boot/grub-x86-64-xen.bin"
```
