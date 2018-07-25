1. Unmask it and install.

    ```bash
    echo "games-server/steamcmd ~amd64" >> /etc/portage/package.accept_keywords/steamcmd
    mkdir -p /etc/portage/package.license/
    echo ">=games-server/steamcmd-1.0 Steam" >> /etc/portage/package.license/steamcmd
    cd /etc
    git add /etc/portage/package.accept_keywords/steamcmd /etc/portage/package.license/steamcmd
    git commit -m "Steamcmd - Unmask & License"
    emerge -avt steamcmd
    ```
2. Update the steamcmd instance from valve.

    ```bash
    cd /opt/steamcmd
    runuser -l steamcmd -c './steamcmd.sh' -s /bin/bash
    ```
