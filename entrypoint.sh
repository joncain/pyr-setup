#!/bin/bash

rails -v &>/dev/null
if [[ $? -gt 0 ]]; then
  echo "Installing Rails..."
  gem install nokogiri -v 1.12.5
  gem install rails -v 4.2.11.1
else
  echo "Rails already installed...skip install"
fi

echo "Adding git config settings"
git config --global --add safe.directory /app/pyr
git config --global url."https://github.com/".insteadOf git://github.com/

echo "Modifying /etc/hosts"
# https://github.com/locomotivecms/wagon/issues/340
# strip "localhost" from loopback
cat /etc/hosts | sed 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' | sponge /etc/hosts

echo "Removing existing server.pid file"
# This is obviously monat specific.
rm /app/pyr/clients/monat/tmp/pids/server.pid 2>/dev/null

echo "Running: ${@}"
$@