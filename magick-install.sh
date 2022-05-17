#!/bin/bash

# Image Magick keeps incrementing the version (the suffix -xx). This could be
# more robust by fixing this. It's not that much of a problem since we 
# infrequently build this image.
version="ImageMagick-6.9.12-49"

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
