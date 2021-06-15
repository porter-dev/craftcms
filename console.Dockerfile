FROM craftcms/cli:8.0
COPY . /app
CMD ["./craft", "queue/listen"]