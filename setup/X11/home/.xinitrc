#!/bin/sh
#setxkbmap dvorak

# Start the ssh agent
#eval (ssh-agent)

# Start dropbox
dropbox-cli start

# Start Gnome-keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

# Initiate NetworkManager Applet
dbus-launch nm-applet &

# If Xresources is present, load it
[[ -f ~/.Xresources ]] && xrdb ~merge ~/.Xresources

compton -b
#xcompmgr -c &

# Trivial setting to enable video offloading
# See https://wiki.archlinux.org/index.php/PRIME
xrandr --setprovideroffloadsink radeon Intel

# Turn on numlock
numlockx &

# Start X with consolekit
exec ck-launch-session dbus-launch --sh-syntax --exit-with-session i3
#exec i3
