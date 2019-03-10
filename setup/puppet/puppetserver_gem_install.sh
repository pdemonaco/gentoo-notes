#!/bin/bash
cd /opt/puppetlabs/server/apps/puppetserver || exit
echo "jruby-puppet: { gem-home: /opt/puppetlabs/server/data/puppetserver/vendored-jruby-gems }" > jruby.conf
while read -r LINE
do
    java -cp puppet-server-release.jar:jruby-9k.jar clojure.main \
        -m puppetlabs.puppetserver.cli.gem --config jruby.conf \
        -- install --no-ri --no-rdoc "$(echo "${LINE}" | awk '{print $1}')" \
        --version "$(echo "${LINE}" |awk '{print $2}')"
done < /opt/puppetlabs/server/data/jruby-gem-list.txt

echo "jruby-puppet: { gem-home: /opt/puppetlabs/puppet/lib/ruby/vendor_gems }" > jruby.conf
while read -r LINE
do
    java -cp puppet-server-release.jar:jruby-9k.jar clojure.main \
        -m puppetlabs.puppetserver.cli.gem --config jruby.conf \
        -- install --no-ri --no-rdoc "$(echo "${LINE}" |awk '{print $1}')" \
        --version "$(echo "${LINE}" |awk '{print $2}')"
done < /opt/puppetlabs/server/data/mri-gem-list.txt
