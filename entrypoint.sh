#!/bin/bash

. /usr/share/rvm/scripts/rvm
rvm --default use 2.6.6

rails -v &>/dev/null
if [[ $? -gt 0 ]]; then
  echo "Installing Rails..."
  gem install nokogiri -v 1.12.5
  gem install rails -v 4.2.11.1
else
  echo "Rails already installed...skip install"
fi

convert --version &>/dev/null
if [[ $? -gt 0 ]]; then
  echo "Installing ImageMagick"
  /root/magick-install.sh
else
  echo "ImageMagick already installed...skip install"
fi

echo "Adding /app/pyr to git safe dirs"
git config --global --add safe.directory /app/pyr

echo "Modifying /etc/hosts"
# https://github.com/locomotivecms/wagon/issues/340
# strip "localhost" from loopback
cat /etc/hosts | sed 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' | sponge /etc/hosts

echo $@
$@