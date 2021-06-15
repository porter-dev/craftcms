FROM craftcms/cli:8.0
COPY ./app /app
WORKDIR /app
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install
CMD ["./craft", "queue/listen"]