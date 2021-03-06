# Initial Install

This procedure documents an install from scratch.

## Disk Preparation
1. Create zvol for the guest.

    ```bash
    ZVOL="xen-pl/XEN/vdisk/gentoo-ext4"
    zfs create -V 16g "${ZVOL}"
    BLOCK_DEVICE="/dev/zvol/${ZVOL}"
    ```
2. Partition the file system and format.

    ```bash

    parted -a optimal "${BLOCK_DEVICE}"
     unit mib
     mklabel gpt
     mkpart primary 1 129
     name 1 boot

     mkpart primary 129 1153
     name 2 swap

     mkpart primary 1153 -1
     name 3 root
    ```
3. Format the filesystems.

    ```bash
    mkfs.ext2 -T small "${BLOCK_DEVICE}-part1"
    mkswap "${BLOCK_DEVICE}-part2"
    mkfs.ext4 "${BLOCK_DEVICE}-part3"
    ```
4. Pass the disk to another gentoo guest.
5. Mount the root file system and create both swap and `/boot`
    
    ```bash
    mount /dev/xvdb3 /mnt/gentoo
    swapon /dev/xvdb2
    mkdir /mnt/gentoo/boot
    mount /dev/xvdb1 /mnt/gentoo/boot
    ```

## Collect Sources 

1. Go to the mountpoint
    
    ```bash
    cd /mnt/gentoo
    ```
2. Download Sources

    ```bash
    wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20160121.tar.bz2
    wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20160121.tar.bz2.DIGESTS
    ```

3. Now that we have the sources, check them out to be sure there is no corruption

    ```bash
    grep --color $(openssl dgst -r -sha512 stage3-amd64-*.tar.bz2 \
        | awk '{print $1}') stage3-amd64-*.tar.bz2.DIGESTS
    ```
    Should see a line that matches

4. Extract the tarball

    ```bash
    tar xvjpf stage3-*.tar.bz2 --xattrs
    ```

#----- etc git tracking -----------------------------------
# Setup git tracking for etc prior to doing anything

#----- Portage Prep-prechroot -----------------------------
# Mix in some steps from chapters 5-6 of the gentoo handbook
#-- make.conf

# Determine instruction set for CPU_FLAGS_X86
emerge -1v app-portage/cpuinfo2cpuflags
cpuinfo2cpuflags-x86

# Collect and store a good mirrorlist
mirrorselect -D -s4 -b10 -o >> /tmp/mirrors

#-- repo configuration
# Note that we can't switch to git-based until git has been installed in the domu
mkdir etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf

#----- Change root to domu --------------------------------
#-- DNS Settings
cp -L /etc/resolv.conf etc/

#-- Link pseudo filesystems
mount -t proc proc /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev
mount --rbind /sys /mnt/gentoo/sys

#-- Actually change root
chroot /mnt/gentoo /bin/bash
env-update; source /etc/profile; export PS1="(chroot) $PS1"; cd

#----- Portage Prep-prechroot -----------------------------
# Configure portage
emerge-webrsync
emerge --sync

# Clear out eselect news...
eselect news read
eselect news purge

#-- Set timezone
echo "America/Detroit" > /etc/timezone
emerge --config sys-libs/timezone-data

#-- Install vim... jesus
emerge -avt vim

#-- Configure locale
# Choose the desired locales in locale.gen and create them
vim /etc/locale.gen
locale-gen

# Pick the correct local eselect
eselect locale list

# Potentially select C and then add LC_CTYPE="en_US.UTF-8"
vim /etc/env.d/02locale

env-update; source /etc/profile; export PS1="(chroot) $PS1"; cd

#----- Kernel ---------------------------------------------
emerge -v sys-kernel/gentoo-sources

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

