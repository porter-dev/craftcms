FROM craftcms/nginx:8.0
COPY ./app /app
WORKDIR /app
USER root
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN composer install --no-interaction
RUN chmod -R 777 composer.* config storage web/cpresources vendor