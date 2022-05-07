FROM ubuntu:bionic

# Install utils
RUN apt-get update && \
    apt-get install -y software-properties-common vim git \
    libmysqlclient-dev \
    wget \
    freetds-dev \
    ffmpeg ffmpegthumbnailer exiftool

# Install RVM
RUN apt-add-repository -y ppa:rael-gc/rvm && \
    apt-get update && \
    apt-get install -y rvm && \
    echo "source /usr/share/rvm/scripts/rvm" >> /root/.bashrc && \
    /bin/bash -c "/usr/share/rvm/bin/rvm install 2.6" && \
    echo "rvm --default use 2.6 >/dev/null" >> /root/.bashrc

COPY ./magick-install.sh /root
RUN /root/magick-install.sh

COPY ./entrypoint.sh /root

CMD ["/bin/bash"]
