#!/bin/bash

version="ImageMagick-6.9.12-48"

cd /root
wget "https://download.imagemagick.org/ImageMagick/download/${version}.tar.gz"
tar xzvf "${version}.tar.gz"
cd "${version}"
./configure
make
make install
ldconfig /usr/local/lib
convert --version
rm "/root/${version}.tar.gz"