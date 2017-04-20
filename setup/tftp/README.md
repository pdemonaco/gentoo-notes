# Installation

1. Emerge the net-ftp/tftp-hpa - this is a port of the OpenBSD tftp implementation.

    ```bash
    sudo emerge -avt net-ftp/tftp-hpa
    ```
2. Create a directory for the tftp daemon to share.

    ```bash
    sudo mkdir /tftp/
    sudo chmod -R 777 /tftp/
    sudo chown -R nobody /tftp/
    ```
3. Provide basic configuration via the `/etc/conf.d/in.tftpd` file.

    ```bash
    INTFTPD_PATH="/tftp/"
    INTFTPD_OPTS="-R 4096:32767 -s ${INTFTPD_PATH}"
    ```
4. Copy your file or files into the tftp directory and start the daemon

    ```bash
    eselect rc start in.tftpd
    ```
