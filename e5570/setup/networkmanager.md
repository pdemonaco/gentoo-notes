# Prepare Installation

Make sure the kernel settings are established as described by the gentoo 
setup article.

https://wiki.gentoo.org/wiki/NetworkManager

```bash
cd /etc
echo "net-misc/networkmanager ~amd64" >> /etc/portage/package.accept_keywords/networkmanager
git add /etc/portage/package.accept_keywords/networkmanager
echo "net-misc/networkmanager resolvconf" >> /etc/portage/package.use/networkmanager
echo "app-crypt/pinentry gnome-keyring" >> /etc/portage/package.use/networkmanager
git add /etc/portage/package.use/networkmanager
```

Add yourself to plugdev so that network changes can be made without becoming
superuser

```bash
usermod -a -G plugdev phil
```

Install network manager 

```bash
emerge -avtn net-misc/networkmanager gnome-extra/nm-applet
```

Remove any existing network interface from current runlevels and add network manager.

```bash
for LEVEL in $(eselect rc list | 
    awk '$0 ~ "^  [[:alpha:]]+" { if( $2 ~ "[[:alpha:]]+") print $2; }' 
    | sort | uniq)
do
    for SERVICE in $(eselect rc show 
        "${LEVEL}" | awk '/^  net\./ {print $1}')
    do
        eselect rc delete "${SERVICE}" "${LEVEL}"
    done
done
eselect rc start NetworkManager
eselect rc add NetworkManager default
```
