#!/bin/bash

set -x
client="${2}"

rails -v &>/dev/null
if [[ $? -gt 0 ]]; then
  gem install nokogiri -v 1.12.5
  gem install rails -v 4.2.11.1
fi

git config --global --add safe.directory /app/pyr
git config --global url."https://github.com/".insteadOf git://github.com/

# https://github.com/locomotivecms/wagon/issues/340
# strip "localhost" from loopback
cat /etc/hosts | sed 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' | sponge /etc/hosts

rm "/app/pyr/clients/${client}/tmp/pids/server.pid" 2>/dev/null

$@