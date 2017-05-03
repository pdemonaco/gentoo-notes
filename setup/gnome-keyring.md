This is primarily based on the discussion on both 
[Nurdletech](https://wiki.archlinux.org/index.php/GNOME_Keyring) and the 
[Arch wiki](https://wiki.archlinux.org/index.php/GNOME/Keyring).

# Installation

This step is gairly straightforward, simply install the keyring and a couple useful utilities for troubleshooting.

```bash
emerge -avtn gnome-keyring seahorse 
```
# Starting at Login

1. Add the following lines to `/etc/pam.d/login`.

    ```bash
    # Insert 'auth       optional     pam_gnome_keyring.so'
    sed -i -r '/auth\s+include\s+system-local-login/a auth       optional     pam_gnome_keyring.so' /etc/pam.d/login
    # Insert 'session    optional     pam_gnome_keyring.so    auto_start'
    sed -i -r '/session\s+include\s+system-local-login/a session    optional     pam_gnome_keyring.so' /etc/pam.d/login
    ```
2. Add the following line to `/etc/pam.d/passwd`.

    ```bash
    # Insert 'password   optional     pam_gnome_keyring.so'
    sed -i -r '/password\s+include\s+system-auth/a password   optional     pam_gnome_keyring.so' /etc/pam.d/passwd
    ```
3. Update your git repo in `/etc` if you're doing that.

    ```bash
    cd /etc
    git add /etc/pam.d/login
    git add /etc/pam.d/passwd
    ```

# Initialization

## .xinitrc

My installs tend to be fairly light so I usually start X with `startx`. The following statement or something similar should be in your `~/.xinitrc` file.

```bash
# Get gnome-keyring's variables exported
export $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
```

Make sure this is done __AFTER__ dbus is started for the session!!
