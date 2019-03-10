# Installation

## Puppet Server

1. Unmask the current version of puppet-server. No reason to use the super old 2.7 variant.

    ```bash
    cd /etc
    echo "app-admin/puppetserver puppetdb" > /etc/portage/package.use/puppet
    echo "app-admin/puppet-agent puppetdb" > /etc/portage/package.use/puppet
    git add /etc/portage/package.use/puppet
    cd -
    ```
3. Ensure cups, gtk, and X are excluded from the build process. Additionally, add headless-awt support as this machine has no head...

    ```bash
    cd /etc
    echo "dev-java/icedtea-bin headless-awt" > /etc/portage/package.use/icedtea-bin
    echo "dev-java/icedtea-bin -nsplugin" > /etc/portage/package.use/icedtea-bin
    git add /etc/portage/package.use/icedtea-bin
    cd -
    ```
2. Install puppet-server.

    ```bash
    emerge -avt app-admin/puppetserver 
    ```
3. Create a new disk for the code subdirectories. No real need to do this other than the fact that we already have a git repository at `/etc` and `/etc/puppetlabs/code` is going to have subdirectories that are repositories.

    ```bash
    # Partition the disk 
    DISK="/dev/xvdb"
    parted -a optimal "${DISK}"
    mklabel gpt
    unit mib
    mkpart 1 1 -1
    name 1 puppet-code
    quit

    # Format the disk
    mkfs.ext4 "${DISK}1"

    # Update /etc/fstab so it actually gets mounted
    cd /etc/
    echo '${DISK}1              /etc/puppetlabs/code            ext4            noatime         0 1' >> /etc/fstab
    git add fstab
    cd -
    ```
3. Perform some configuration per the build log.

    ```bash
    puppet config set --section master vardir  /opt/puppetlabs/server/data/puppetserver
    puppet config set --section master logdir  /var/log/puppetlabs/puppetserver
    puppet config set --section master rundir  /run/puppetlabs/puppetserver
    puppet config set --section master pidfile /run/puppetlabs/puppetserver/puppetserver.pid
    puppet config set --section master codedir /etc/puppetlabs/code
    ```
4. Install the puppet server gems via [this script](./puppetserver_gem_install.sh).
5. Add puppetserver to the default run level and start it up.

    ```bash
    eselect rc start puppetserver
    eselect rc add puppetserver default
    ```

## Puppet Agent

1. Install puppet-agent on the puppet server node.

    ```bash
    emerge -avtn puppet-agent
    ```
2. Start the agent process locally and add it to the default run-level.

    ```bash
    eselect rc start puppet
    eselect rc add puppet default
    ```

## Puppet DB

1. Unmask puppetdb itself.

    ```bash
    echo "app-admin/puppetdb ~amd64" >> /etc/portage/package.accept_keywords/puppet
    git add /etc/portage/package.accept_keywords/puppet
    ```
2. TBD.
