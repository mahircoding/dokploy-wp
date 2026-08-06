ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-fpm-bookworm

LABEL maintainer="Dokploy WordPress Hosting"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    wget \
    nano \
    vim \
    zip \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libmagickwand-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    imagemagick \
    mariadb-client \
    redis-tools \
    cron \
    supervisor \
    libxml2-utils

RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp

RUN docker-php-ext-install \
    mysqli \
    pdo_mysql \
    exif \
    intl \
    zip \
    gd \
    opcache \
    bcmath

RUN pecl install redis imagick

RUN docker-php-ext-enable redis imagick

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

COPY php.ini /usr/local/etc/php/php.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

COPY docker-entrypoint.sh /usr/local/bin/
COPY healthcheck.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD ["healthcheck.sh"]

CMD ["php-fpm"]