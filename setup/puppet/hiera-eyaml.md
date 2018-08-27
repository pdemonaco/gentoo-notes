## Install

1. Install it on your machine for your user.

    ```bash
    gem install hiera-eyaml
    # You'll also probably want to add it to your PATH somehow. I did via zshrc.local
    ```
2. Install it on the puppet server.

    ```bash
    puppetserver gem install hiera-eyaml
    ```

## Setup

1. Generate a new set of keys on your local machine.

    ```bash
    eyaml createkeys
    ```
2. Send these keys to the puppet server.

    ```bash
    KEY_DIR="./keys"
    PUPPET_SERVER="puppet01.demona.co"
    tar -cvf keys.tar "${KEY_DIR}"
    scp keys.tar "${PUPPET_SERVER}:/tmp/"
    ```
3. Create the appropriate directory structure on the puppet server and extract the tar.

    ```bash
    EYAML_DIR="/etc/puppetlabs/puppet/eyaml"
    KEY_TAR="/tmp/keys.tar"

    # Create the target directory and extract the tar
    mkdir -p "${EYAML_DIR}"
    tar -C "${EYAML_DIR}" -xvf "${KEY_TAR}" --strip-components=1
    
    # Fix permissions
    chown -R puppet:puppet "${EYAML_DIR}"
    chmod -R 0500 "${EYAML_DIR}"
    chmod 0400 "${EYAML_DIR}"/*.pem

    # Verify 
    ls -lha "${EYAML_DIR}"

    # Delete the tar
    rm "${KEY_TAR}"
    ```
