
ARG PHP_VERSION

FROM php:${PHP_VERSION}-cli

ARG HOST_UID
ARG TIMEZONE
ARG DEPLOYMENT_PATH
ARG SWOOLE_VERSION

WORKDIR ${DEPLOYMENT_PATH}

USER root

# system
RUN apt-get update && apt-get install -qy --no-install-recommends \
    git \
    # composer, to manage dependencies from composer.json
    unzip

# timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo ${TIMEZONE} > /etc/timezone && \
    printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini && \
    date

# swoole
RUN git clone https://github.com/swoole/swoole-src.git && \
    cd swoole-src && \
    git checkout v${SWOOLE_VERSION} && \
    phpize && \
    ./configure && \
    make && \
    make install
COPY docker-php-ext-swoole.ini /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini

COPY php.ini /usr/local/etc/php/conf.d/php.ini

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer --version

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# permissions
RUN usermod -u ${HOST_UID} www-data && \
    chown www-data:www-data /var/www

USER www-data
