## Intel HD Graphics

1. Ensure sys-kernel/linux-firmware is installed.
2. Use the following command to determine which firmware file is needed:

    ```bash
    grep -B 3 'MODULE_FIRMWARE.*SKL' drivers/gpu/drm/i915/intel_guc_loader.c \
        drivers/gpu/drm/i915/intel_csr.c
    ```
3. Set the following kernel flags.
    
    ```bash
    CONFIG_AGP=y
    CONFIG_AGP_INTEL=y
    CONFIG_DRM=y
    CONFIG_DRM_FBDEV_EMULATION=y
    CONFIG_DRM_I915=M
    ```
4. Update make.conf with the appropriate video cards settings.

    ```bash
    VIDEO_CARDS="intel i965"
    ```
5. Add module `i915` to your modules list.

    ```bash
    cd /etc
    CONF="/etc/conf.d/modules"
    MODULE="i915"
    (grep "${MODULE}" "${CONF}")
    RC=$?
    if [ "${RC}" -ne 0 ]
    then
      sed -i -r 's/^(modules="[[:alnum:]_ ]+)/\1 '"${MODULE}"'/' "${CONF}"
      git add "/etc/conf.d/modules"
    fi
    ```

Further details can be found [here](https://wiki.gentoo.org/wiki/Intel).
