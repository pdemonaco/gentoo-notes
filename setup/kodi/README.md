# Installation

1. Add support for the bleeding edge kodi version and ensure we're choosing relevant use flags.

      ```bash
      echo "media-tv/kodi ~amd64" >> /etc/portage/package.accept_keywords/kodi
      echo "dev-libs/libcec ~amd64" >> /etc/portage/package.accept_keywords/kodi
      echo "media-libs/libjpeg-turbo ~amd64" >> /etc/portage/package.accept_keywords/kodi
      echo "media-libs/taglib ~amd64" >> /etc/portage/package.accept_keywords/kodi
      echo "media-fonts/noto ~amd64" >> /etc/portage/package.accept_keywords/kodi
      echo "media-tv/kodi nfs" >> /etc/portage/package.use/kodi
      echo "media-tv/kodi sftp" >> /etc/portage/package.use/kodi
      echo "media-tv/kodi system-ffmpeg" >> /etc/portage/package.use/kodi
      echo "media-tv/kodi bluray" >> /etc/portage/package.use/kodi
      echo "media-tv/kodi cec" >> /etc/portage/package.use/kodi
      ```
2. Update the local `/etc` git repo if applicable.

      ```bash
      cd /etc
      git add /etc/portage/package.use/kodi
      git add /etc/portage/package.accept_keywords/kodi
      git commit -m 'unmask kodi packages'
      ```
3. Create the local user to run kodi.

    ```bash
    useradd -m -G audio,cdrom,video,cdrw,usb,users,plugdev kodi
    ```
    *Why doesn't the ebuild handle this?*

4. Add a policy to allow the kodi user to shutdown the machine. This file should be `/etc/polkit-1/rules.d/60-kodi.rules`

    ```bash
    polkit.addRule(function(action, subject) {
            if (( (action.id.indexOf("org.freedesktop.udisks.") == 0) || 
                  (action.id.indexOf("org.freedesktop.upower.")== 0) || 
                  (action.id.indexOf("org.freedesktop.consolekit.")== 0) ) 
                && subject.user=="kodi") {
              return polkit.Result.YES;
            }
    });
    ```
    Add to git if you do that sort of thing.

    ```bash
    cd /etc/
    git add /etc/polkit-1/rules.d/60-kodi.rules
    git commit -m 'Allow Kodi to shutdown the machine'
    ```

# Configure Environment

1. Configure an appropriate .xinitrc file for the kodi user similar to [this](kodi/system/home/kodi/.xinitrc)
2. Create a simple i3 config file for kodi similar to [this one](kodi/system/home/kodi/.i3/config). The key here is that kodi must be started by i3.

# Enable Automatic Start

1. Build a simple profile that automatically starts x for Kodi and install int in `/home/kodi`. [This one](kodi/system/home/kodi/.bash_profile) provides a good starting point.
2. Install `mingetty` so we can actually spawn the virtual terminal at boot.

    ```bash
    emerge -avtn net-dialup/mingetty
    ```
3. Add the following line to the end of `/etc/inittab` to trigger the auto-start of kodi.

    ```bash
    cd /etc/
    echo '
    # Autostart kodi
    c9:2345:respawn:/sbin/mingetty --autologin kodi tty9' > /etc/inittab
    git add /etc/inittab
    ```

# Configure NFS Mounts

1. Ensure the NFS client daemon is installed.

    ```bash
    emerge -avt net-fs/nfs-utils
    ```
2. Add the nfsclient to the default runlevel.

    ```bash
    eselect rc add nfsclient default
    eselect rc start nfsclient
    ```
3. Create local directories for the mount points

    ```bash
    mkdir -p /mnt/media/movies
    mkdir -p /mnt/media/music
    mkdir -p /mnt/media/tv-series
    ```
4. Configure the mount points in `/etc/fstab`

    ```config
    nas-nfs.demona.co:/mnt/media-pl/movies      /mnt/media/movies       nfs     rw,_netdev,proto=tcp    0 0
    nas-nfs.demona.co:/mnt/media-pl/tv-series   /mnt/media/tv-series    nfs     rw,_netdev,proto=tcp    0 0
    nas-nfs.demona.co:/mnt/media-pl/music       /mnt/media/music        nfs     rw,_netdev,proto=tcp    0 0
    ```
5. Add the netmount daemon to default as well so it can handle mounts at boot.

    ```bash
    # Note that this may already be in place
    eselect rc add netmount default
    ```

