## Radeon Configuration

1. Ensure that `sys-kernel/linux-firmware` is installed.
2. Set the following kernel flags:

    ```bash
    CONFIG_DRM_RADEON=m
    CONFIG_DRM_RADEON_USERPTR=m
    CONFIG_FB_RADEON=n
    ```
3. Update make.conf with the appropriate video card settings:

    ```bash
    VIDEO_CARDS="radeon radeonsi"
    ```
4. Ensure the radeon module is loaded at boot

    ```bash
    CONF="/etc/conf.d/modules"
    MODULE="radeon"
    (grep "${MODULE}" "${CONF}" >/dev/null)
    RC=$?
    if [ "${RC}" -ne 0 ]
    then
      sed -i -r 's/^(modules="[[:alnum:]_ ]+)/\1 '"${MODULE}"'/' "${CONF}"
      git add "/etc/conf.d/modules"
    fi
    ```

See [this article](https://wiki.gentoo.org/wiki/Radeon) for further details.
