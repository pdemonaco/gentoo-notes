
# Turn on numlock
numlockx &

# Make sure D-Bus is running
# See http://www.nurdletech.com/linux-notes/agents/keyring.html for more detail
if [[ -z "${DBUS_SESSION_BUS_ADDRESS}" ]];
then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

# Get gnome-keyring's variables exported
export $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)

#==== Kodi Settings
# Use a random pattern instead of a blank screen
/usr/bin/xset s noblank

# Turn off screensaver
/usr/bin/xset s off

# Disable energy star features
usr/bin/xset -dpms

# Start the X - i3 will start Kodi
exec i3
