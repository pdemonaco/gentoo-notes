# Installation

1. Ensure layman is installed.
2. Add the overlay per instructions [here](https://github.com/pdemonaco/overlay).
3. Install the dedicated server.

    ```bash
    cd /etc/
    mkdir -p /etc/portage/package.accept_keywords
    echo "games-server/factorio-ded ~amd64" >> /etc/portage/package.accept_keywords/factorio-ded
    git add /etc/portage/package.accept_keywords/factorio-ded
    emerge -avt factorio-ded
    ```

# Base Configuration

1. Set the authentication token in `/etc/factorio/server-settings.json` so the server registers properly.
2. Generate a new save file.

    ```bash
    rc-service factorio-ded gen_new_save
    ```
3. Finally, start the server and allow connections.

    ```bash
    eselect rc start factorio-ded
    eselect rc add factorio-ded default
    ```
