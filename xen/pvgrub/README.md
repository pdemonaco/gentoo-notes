GRUB2 Xen PV Host Config
========================

Largely taken from this excellent blog post: https://blog.xenproject.org/2015/01/07/using-grub-2-as-a-bootloader-for-xen-pv-guests/

1. Ensure the xen target is included in your grub2 targets (make.conf)
```bash
GRUB_PLATFORMS="xen"
```

   Note that if wasn't originally present in your grub install you will need to remerge it.  

2. Make a working directory to prepare your bootloader files
```
mkdir /tmp/pvgrub
cd /tmp/pvgrub
```
3. Download grub.cfg and grub-bootstrap.cfg
4. Create the "memdisk" which is really just a tar of the grub.cfg file
```
tar cf memdisk.tar grub.cfg
```
5. Build the new image with grub-mkimage
```
grub2-mkimage -O x86_64-xen -c grub-bootstrap.cfg -m memdisk.tar -o grub-x86-64-xen.bin /usr/lib/grub/x86_64-xen/*.mod
```
6. Now you can manage your PV guest grub.cfg as if it were a standalone machine by replacing the "kernel" directive in your config file with something similar to the following
```bash
kernel = "/xen/boot/grub-x86-64-xen.bin"
```
