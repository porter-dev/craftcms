FROM php:8.4-apache-trixie AS base

COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions bcmath gd intl opcache pdo_pgsql zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY docker/php.ini "$PHP_INI_DIR/conf.d/craft.ini"

RUN a2enmod rewrite headers
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo 'Listen ${PORT}' > /etc/apache2/ports.conf \
    && echo ok > /var/www/healthz

WORKDIR /app

FROM base AS vendor
COPY --from=composer:2.10 /usr/bin/composer /usr/local/bin/composer
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --no-scripts --no-autoloader
COPY . .
RUN composer dump-autoload --no-dev --optimize

FROM base
ENV PORT=8080 \
    CRAFT_ENVIRONMENT=production \
    CRAFT_DEV_MODE=false \
    CRAFT_ALLOW_ADMIN_CHANGES=false \
    CRAFT_RUN_QUEUE_AUTOMATICALLY=false \
    CRAFT_STREAM_LOG=true \
    CRAFT_LICENSE_KEY_PATH=/app/storage/license.key
COPY --from=vendor /app /app
RUN mkdir -p config/project storage web/cpresources \
    && chown -R www-data:www-data config/project storage web/cpresources
USER www-data
EXPOSE 8080
CMD ["apache2-foreground"]
