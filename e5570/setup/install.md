# File Systems

Useful Definitions
```bash
DISK1="/dev/sda"
POOL="sys-pl"
```

## Partitioning

Create the partition table on the primary hard disk. Note that it should be optimally aligned. Also, switch to mebibytes.

```bash
parted -a optimal /dev/sda
unit mib
mklabel gpt
```
From within parted create a 500 MiB file system for Grub's EFI implementation. 

Parted `set boot on` flags the partition for EFI system use.

```bash
mkpart primary 1 501
name 1 efi
set 1 boot on
```

Create partitions for Kernel files and leave the remainder for root.

```bash
mkpart primary 501 629
name 2 boot

mkpart primary 629 -1
name 3 root
```

## Formatting

Specific components of the system require certain file system types. In particular, the EFI System Partition must be FAT32.

```bash
mkdosfs -F 32 -n EFI "${DISK1}1"
```
The kernel file system is primarily read-only so we may as well use ext2.
```bash
mkfs.ext2 -T small "${DISK1}2"
```

### Crypto

Create and open the crypto vault

```bash
cryptsetup -c twofish-xts-essiv:sha256 -s 512 luksFormat "${DISK1}3"
```

You'll be asked the following
1. Are you sure you want to overwrite? YES
2. Enter your passphrase

Now open the libary

```bash
cryptsetup luksOpen "${DISK1}"3 "${POOL}-crypt0"
```

Based on:
https://thestaticvoid.com/post/2013/10/26/how-i-do-encrypted-mirrored-zfs-root-on-linux/
https://wiki.gentoo.org/wiki/DM-Crypt_LUKS

### ZFS Filesystems

Create the base filesystem. Eventually this should be mirrored, but whatever.

```bash
zpool create -o ashift=12 -o autoexpand=on -o feature@lz4_compress=enabled \
    -o cachefile=/tmp/zpool.cache \
    -O normalization=formD -m none -R /mnt/gentoo "${POOL}" \
    "${POOL}-crypt0"
```

Create our filesystems

```bash
#Swap
zfs create "${POOL}/swap" -V 8G -b 4K
mkswap "/dev/${POOL}/swap"

# Root
zfs create -o mountpoint=none ${POOL}/ROOT
zfs create -o mountpoint=/ -o compression=lz4 ${POOL}/ROOT/gentoo

# home
zfs create -o mountpoint=/home -o compression=lz4 ${POOL}/HOME

# portage
zfs create -o mountpoint=none ${POOL}/GENTOO
zfs create -o mountpoint=/usr/portage -o compression=lz4 ${POOL}/GENTOO/portage
zfs create -o mountpoint=/usr/portage/distfiles ${POOL}/GENTOO/distfiles

# portage (build)
# Extra settings like sync off & compression
zfs create -o mountpoint=/var/tmp/portage -o compression=lz4 -o sync=disabled ${POOL}/GENTOO/build-dir

# packages
zfs create -o mountpoint=/usr/portage/packages ${POOL}/GENTOO/packages

# ccache directory
zfs create -o mountpoint=/var/tmp/ccache -o compression=lz4 ${POOL}/GENTOO/ccache
```

## Turn on Swap

```bash
swapon "/dev/${POOL}/swap"
```

# Collect Sources 

Go to the mount point

```bash
cd /mnt/gentoo
```

Download Sources

```bash
wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20160602.tar.bz2
wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20160602.tar.bz2.DIGESTS
```

Now that we have the sources, check them out for corruption

```bash
grep --color $(openssl dgst -r -sha512 stage3-amd64-*.tar.bz2 | awk '{print $1}') stage3-amd64-*.tar.bz2.DIGESTS
```
Extract the tarball

```bash
tar xvjpf stage3-*.tar.bz2 --xattrs
```

# System Configuration

## Change Root

Copy over our resolv.conf file to ensure DNS resolution continues to operate.

```bash
cp -L /etc/resolv.conf etc/
```

Link pseudo filesystems.

```bash
mount -t proc proc /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev
mount --rbind /sys /mnt/gentoo/sys
```

Actually change over to the local root environment.

```bash
chroot /mnt/gentoo /bin/bash
env-update; source /etc/profile; export PS1="(chroot) $PS1"; cd
```

## Configure portage

Copy in a good make.conf file to start. Once it's in place, pass in an additional
set of parameters using the CPU flags utility

```bash
emerge -1v app-portage/cpuinfo2cpuflags
cpuinfo2cpuflags-x86
```

With those changes in place, sync an updated copy of the portage tree and remerge with current config.

```bash
emerge --sync
emerge -avtuDN world
```

Clear out eselect news...

```bash
eselect news read
eselect news purge
```

Collect some good mirrors and add the updated record to make.conf.

```bash
emerge -1av mirrorselect
mirrorselect -D -s4 -b10 -o >> /tmp/mirrors
```

### Git based Portage 

Switch to git-based portage tree for gentoo.

```bash
mkdir etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
```

Modify the new gentoo.conf to reflect this change

```ini
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /usr/portage
sync-type = git
sync-uri = https://github.com/gentoo-mirror/gentoo.git
auto-sync = yes
```

Unmount the distfiles and packages file systems.

```bash
zfs umount sys-pl/GENTOO/distfiles
zfs umount sys-pl/GENTOO/packages
```

Clear out the existing portage tree

```bash
cd /usr/portage
rm -r ./*
emerge --sync
```

Remount the two file systems which were previously unmounted.

```bash
zfs umount sys-pl/GENTOO/distfiles
zfs umount sys-pl/GENTOO/packages
```

## Base configuration

Definitely mix in steps from chapters 5-6 of the handbook here, but first
install vim - don't be a savage.

```bash
emerge -avtn app-editors/vim
```

Once we have vim we need it to be the default editor for our system.

```bash
eselect editor list
eselect editor set 3
```
![Setting the editor](img/editor-select.png)

### Git Tracking for /etc

Basic git tracking for etc.

```bash
cd /etc
git init
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

### Timezone Data

```bash
echo "America/Detroit" > /etc/timezone
emerge --config sys-libs/timezone-data
```

### Locale

Prep the locale list

```bash
git add /etc/locale.gen
vim /etc/locale.gen
locale-gen
```

Choose the locale you want to be the primary.

![Locale List](img/locale-list.png)

```bash
eselect locale set 4
```

## Kernel

Emerge the standard gentoo sources. Hardened would be nice, but it's 
problematic for desktop use.

```bash
emerge -v sys-kernel/gentoo-sources
KERNEL_VERSION="4.4.6-gentoo"
cd /usr/src/linux
```

Next we need to assemble a listing of the relevant devices via lspci. Note 
that this may need to be executed from outside of the chroot environment.

```bash
emerge --ask sys-apps/pciutils
lspci -k
```

![Device Listing](img/lspci.png)

This system utilizes the following kernel drivers:

| Device Name | Module Name | Kernel Flag | Description |
---------------------------------------------------------
| Network controller | iwlmvm | CONFIG_IWLMVM | Intel Wireless 8260 |
| Unassigned class | rtsx_pci | CONFIG_MFD_RTSX_PCI | Realtek PCI-E card reader |
| Display controller | radeon | | AMD R7 M370 Graphics Card |
| Ethernet controller Intel Corporation Ethernet Connection (2) I219-LM | e1000e | CONFIG_E1000E | Intel I219-LM |
| Intel Corporation Sunrise Point-H SMBus | i2c_i801 | CONFIG_I2C_I801 | i2c interface |
| Audio device Intel Corporation Sunrise Point-H HD Audio | snd-hda-intel | CONFIG_SND_HDA_INTEL | Intel HD Audio (Azalia) |
| ISA Bridge Intel Corporation Sunrise Point-H LPC Controller | - | CONFIG_SND | Advanced Linux Sound Architecture |
| PCI bridge Intel Corporation Sunrise Point-H PCI Express Root Port | shpchp | CONFIG_HOTPLUG_PCI_SHPC | PCI Hotplug |
| SATA controller Intel Corporation Device a102 | ahci | CONFIG_SATA_AHCI | Intel SATA AHCI Controller |
| Intel Corporation Sunrise Point-H CSME HECI | mei | CONFIG_INTEL_MEI | Intel Management Engine |
| USB controller: Intel Corporation Sunrise Point-H USB 3.0 xHCI Controller | xhci-hcd | CONFIG_USB_XHCI_HCD | USB 3.0 Driver |
| Intel Corporation Device 1903 | CONFIG_INT340X_THERMAL
| VGA compatible controller: Intel Corporation Device 191b | i915 | CONFIG_DRM_I915 | Integrated Graphics |


#-- Prepare the sources
# Copy in a good configuration
KERNEL_VERSION="4.4.6-gentoo"
cd /usr/src/linux

#-- Make the kernel and install
make -j9 && make -j9 modules_install
cp arch/x86_64/boot/bzImage /boot/kernel-${KERNEL_VERSION}-domu00

#----- Initramfs ------------------------------------------
# Using dracut for consistency

#-- Install dracut
echo "sys-kernel/dracut ~amd64" >> /etc/portage/package.accept_keywords/dracut
emerge -av sys-kernel/dracut

#-- create and rename the new initramfs
dracut --xz --kver ${KERNEL_VERSION}
mv initramfs-${KERNEL_VERSION}.img initramfs-${KERNEL_VERSION}-domu00.img

#----- Bootloader -----------------------------------------
# GRUB - because reasons
emerge -av sys-boot/grub:2

# Note that grub is chain-loaded from outside
# no need to "install"
#-- Update grub defaults
# Add this for dvorak
GRUB_CMDLINE_LINUX="vconsole.keymap=dvorak"

#-- Generate grub config
# /boot should be mounted at this point
mkdir /boot/grub
cd /boot
grub2-mkconfig -o grub/grub.cfg

#----- Filesystem Information -----------------------------
# Configure fstab
vim /etc/fstab

#----- Networking -----------------------------------------
# Trivial dhcp config
vim /etc/conf.d/net

#-- Hostname
# Something basic for base install
vim /etc/conf.d/hostname

# Store full hostnames in case DNS is down
vim /etc/hosts

#-- Configure Service
cd /etc/init.d/
ln -s net.lo net.eth0
eselect rc add net.eth0 default

#----- Finalizing Install ---------------------------------

#-- Root Password
passwd

#-- Default Editor
eselect editor list
eselect editor set 3

#-- SSH Must be Executing
eselect rc add sshd default

#-- System Logger
# metalog for the moment - we'll need to do remote logging eventually
emerge -vt app-admin/metalog
eselect rc add metalog default

#-- Cron
emerge -vt sys-process/fcron
eselect rc add fcron default
crontab /etc/crontab

#-- Add the following line to /etc/inittab
echo "c0:2345:respawn:/sbin/agetty 38400 hvc0 linux" >> /etc/inittab

#----- Install Stuff --------------------------------------
#-- system monitor
SYS_MON="sys-process/htop \
    sys-process/lsof \
    sys-process/nmon" 

#-- portage tools
PORTAGE="app-portage/gentoolkit \
    app-portage/layman \
    app-portage/pfl"

#-- network tools
NET_TOOLS="net-analyzer/nmap \
    net-analyzer/traceroute \
    net-dns/bind-tools \
    net-misc/netifrc \
    net-misc/dhcpcd \
    net-firewall/iptables \
    net-misc/netkit-telnetd"

#-- General purpose
GENERAL="app-misc/screen \
    app-editors/vim \
    app-text/tree \
    app-shells/zsh \
    app-admin/sudo"

emerge -avt ${SYS_MON} ${PORTAGE} ${NET_TOOLS} ${GENERAL}

#----- Configure Sudo -------------------------------------
# Uncomment the "wheel" rule
visudo

# %wheel ALL=(ALL) ALL

#----- Prepare User ---------------------------------------
#-- Create User
useradd -m -G users,wheel -s /bin/zsh pdemonaco

#-- Copy over config files
# ~/.zshrc
# ~/.gitconfig
# ~/.vimrc

#----- Unmount File Systems -------------------------------
#-- Virtual File Systems
umount -l /mnt/gentoo/proc /mnt/gentoo/dev /mnt/gentoo/sys

#-- Physical FS
umount /mnt/gentoo/boot
umount /mnt/gentoo

#----- Create Domain Config -------------------------------
# Copy another system
cp /etc/xen/config/gentoo-ext4 /etc/xen/config/<newVM>

# Update the Disk

# Generate Random MAC
xxd -p -l 6 /dev/urandom | awk '{ and_num = strtonum("0xfeffffffffff"); or_num = strtonum("0x020000000000"); numstr = "0x"$1; num = strtonum(numstr); mod_num = and( or( num, or_num ), and_num ); printf "%0x\n", mod_num; }'

# Alternatively, it may be reasonable to copy another zvol
zfs snap xen-pl/XEN/vdisk/gentoo-ext4@pre-clone
zfs send xen-pl/XEN/vdisk/gentoo-ext4@pre-clone | zfs recv xen-pl/XEN/vdisk/ns0

# Update host references
# /etc/hosts
# /etc/conf.d/hostname

# Alter the host keys
/usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
/usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
/usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

