ARG NEXTCLOUD_VERSION=23.0.3

FROM nextcloud:${NEXTCLOUD_VERSION}-apache

# COPY redis-session.ini /usr/local/etc/php/conf.d/redis-session.ini

# add a few handy packages, ghostscript for PDF previews, and limit the number of request workers
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
      vim \
      nano \
      ffmpeg \
      supervisor \
      python3-numpy \ 
      python3-willow \
      python3-asn1crypto \
      python3-cffi \
      python3-cffi-backend \
      python3-scipy \
      python3-nacl \
      python3-cryptography \
      python3-pip \
      libmagickcore-6.q16-6-extra \
      libmagickwand-dev \
      less \
      smbclient \
      libsmbclient-dev \
      clamdscan \
      ghostscript \
#      unrar \
      p7zip \
      p7zip-full && \
    apt-get purge -yqq && \
    sed -i -e 's/MaxRequestWorkers\s*150/MaxRequestWorkers 25/' /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -i -e 's:<policy domain="coder" rights="none" pattern="PDF" />:<policy domain="coder" rights="read | write" pattern="PDF" />:' /etc/ImageMagick-6/policy.xml && \
    chsh www-data -s /bin/bash && \
    apt-get clean

RUN pecl -v install rar
RUN pecl install inotify && docker-php-ext-enable inotify
RUN pecl install smbclient && docker-php-ext-enable smbclient
RUN python3 -m pip install -U pip
RUN python3 -m pip install pillow_heif
RUN python3 -m pip install pywavelets

ARG SCANNER_TOKEN

RUN if [ ! -z "$SCANNER_TOKEN" ] ; then \
      curl https://get.aquasec.com/microscanner > /microscanner && \
      chmod +x /microscanner && \
      ( /microscanner --html "$SCANNER_TOKEN" > /microscanner.html || ( echo Microscanner failed && exit 0 ) ) && \
      rm -rf /microscanner ; \
    fi 
