FROM craftcms/cli:8.0
COPY ./app /app
CMD ["./craft", "queue/listen"]