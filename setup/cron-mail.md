Simple guide to get cron mailing via gmail or similar external authorized SMTP server. This is largely taken from [here](https://www.howtogeek.com/51819/how-to-setup-email-alerts-on-linux-using-gmail/) and adapted to gentoo.

Also based on [this](https://wiki.archlinux.org/index.php/Msmtp).

# Installation

This is assuming
* cron is already installed and running, 
* you have a safe gmail account to use, 
* and you're using gnome-keyring.

1. Emerge `mail-mta/msmtp`

    ```bash
    cd /etc
    echo "mail-mta/msmtp libsecret" >> /etc/portage/package.use/msmtp
    echo "mail-mta/msmtp gnutls" >> /etc/portage/package.use/msmtp
    git add /etc/portage/package.use/msmtp
    sudo emerge -vt mail-mta/msmtp
    ```
2. Perform basic configuration in `/etc/msmtprc`

    ```bash
    defaults
    auth            on
    tls             on
    tls_trust_file  /etc/ssl/certs/ca-certificates.crt
    auto_from on
    maildomain demona.co

    account     default
    host        smtp.gmail.com
    port        587
    user        <username>
    password    <app password in plain text>
    ```

3. Send a test email.

    ```bash
    echo "hello there username." | msmtp -a default <your email>
    ```

# Configure Root Mail

1. Create an aliases file to track mappings of local emails to real addresses.

    ```bash
    echo "default:    <email@example.com>" >> /etc/msmtp_aliases
    cd /etc/
    git add msmtp_aliases
    ```
2. Add an entry to `/etc/msmtprc` which references the new aliases file.

    ```bash
    aliases /etc/msmtp_aliases
    ```
3. Test the config.

    ```bash
    sendmail "Hello root, this is a test" | sendmail root
    ```

