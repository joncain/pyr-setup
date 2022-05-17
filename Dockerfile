FROM ruby:2.6.6

# Install utils
RUN apt-get update && \
    apt-get install -y software-properties-common vim git moreutils \
    freetds-dev \
    wget \
    ffmpeg ffmpegthumbnailer exiftool libmagickwand-dev

COPY ./magick-install.sh /root
RUN /root/magick-install.sh

WORKDIR /app/pyr

# Note: ENTRYPOINT and CMD cannot both be string values. They can both be array values,
# and ENTRYPOINT can be an array value and CMD can be a string value; but if ENTRYPOINT
# is a string value, CMD will be ignored. This is an unfortunate but unavoidable
# consequence of the way argument strings are converted to arrays. This is among the
# reasons I always recommend specifying arrays whenever possible.