#!/bin/bash

# Taken from arch wiki 
# https://wiki.archlinux.org/index.php/GNOME_Keyring

# Add the following line to /etc/pam.d/login
echo "session    optional pam_gnome_keyring.so    auto_start" >> /etc/pam.d/login

# Add the following line to /etc/pam.d/passwd
echo "password   optional pam_gnome_keyring.so" >> /etc/pam.d/passwd

# Update xinitrc with the following
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
