#!/bin/bash
cd /root
wget https://download.imagemagick.org/ImageMagick/download/ImageMagick-6.9.12-47.tar.gz
tar xzvf ImageMagick-6.9.12-47.tar.gz
cd ImageMagick-6.9.12-47
./configure
make
make install
ldconfig /usr/local/lib
convert --version
