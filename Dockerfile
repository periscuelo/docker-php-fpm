FROM php:fpm
LABEL maintainer="Periscuelo"

RUN requirements="nano cron mariadb-client libonig-dev libpng-dev libmcrypt-dev libmcrypt4 libcurl3-dev libzip-dev unzip libxml2-dev libfreetype6 libjpeg62-turbo libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get update && apt-get install -y --no-install-recommends $requirements && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-install gd \
    && pecl install mcrypt-1.0.3 \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install soap \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && requirementsToRemove="libmcrypt-dev libcurl3-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove

ENV COMPOSER_HOME /composer
ENV PATH /composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php \
&& mv composer.phar /usr/local/bin/composer \
&& chmod +x /usr/local/bin/composer

RUN composer global require phpunit/phpunit

EXPOSE 9000

CMD ["php-fpm"]
