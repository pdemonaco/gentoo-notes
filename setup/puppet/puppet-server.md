# Installation

## Puppet Server

1. Unmask the current version of puppet-server. No reason to use the super old 2.7 variant.

    ```bash
    cd /etc
    echo "app-admin/puppetserver ~amd64" > /etc/portage/package.accept_keywords/puppet
    echo "app-admin/puppetdb ~amd64" > /etc/portage/package.accept_keywords/puppet
    echo "app-admin/puppet-agent ~amd64" > /etc/portage/package.accept_keywords/puppet
    git add /etc/portage/package.accept_keywords/puppet
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

## Puppet DB
