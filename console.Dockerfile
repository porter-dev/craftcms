FROM craftcms/cli:8.0
COPY ./app /app
WORKDIR /app
USER root
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN chmod -R 777 composer.* config storage vendor web/cpresources
RUN composer install
CMD ["./craft", "queue/listen"]