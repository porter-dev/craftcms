FROM craftcms/cli:8.0
COPY . /app
WORKDIR /app
RUN composer install
CMD ["./craft", "queue/listen"]