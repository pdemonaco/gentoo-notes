1. List devices with `aplay -L` and `aplay -l`.
1. Test output using the names from `aplay -L`

    ```bash
    DEVICE='default'
    FILE='${HOME}/downloads/a2002011001-e02.wav"
    aplay -D "${DEVICE}" "${FILE}"
    ```
1. Construct new `${HOME}/.asoundrc` and `/etc/asound.conf`
