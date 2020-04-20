FROM php:7.2-fpm

RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN echo "Acquire::Check-Valid-Until "0";" > /etc/apt/apt.conf.d/10no--check-valid-until

ARG DEBIAN_FRONTEND=noninteractive

ARG UNAME=deployer
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
     cron \
     logrotate \
     zip \
     git \
     gzip \
     libjpeg-dev \
     libpng-dev \
     libbz2-dev \
     zlib1g-dev \
     libssh2-1-dev \
     libicu-dev \
     libxslt-dev \
     libsodium-dev \
     g++ \
     libfreetype6-dev \
     libzip-dev \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN docker-php-ext-configure \
        gd --with-freetype-dir=/usr/include/ \
            --with-jpeg-dir=/usr/include/

RUN docker-php-ext-configure \
        opcache --enable-opcache

RUN docker-php-ext-configure \
        intl

RUN docker-php-ext-install \
      opcache \
      pdo_mysql \
      bcmath \
      bz2 \
      calendar \
      exif \
      gettext \
      mbstring \
      mysqli \
      pcntl \
      sockets \
      sysvmsg \
      sysvsem \
      sysvshm \
      gd \
      intl \
      xsl \
      soap \
      zip

RUN curl -sS https://getcomposer.org/installer | \
  php -- --version=1.9.0 --install-dir=/usr/local/bin --filename=composer

RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY php.ini /usr/local/etc/php/php.ini
COPY conf.d/10-xdebug.ini /usr/local/etc/php/conf.d/10-xdebug.ini

USER $UNAME:

EXPOSE 9000