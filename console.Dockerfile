FROM craftcms/cli:8.0
COPY ./app /app
WORKDIR /app
USER root
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN chmod -R 777 composer.* config storage web/cpresources
RUN composer install --no-interaction
RUN php craft migrate/all
RUN php craft project-config/apply
CMD ["./craft", "queue/listen"]