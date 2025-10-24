FROM alpine:3.22.2

RUN apk update && \
    apk add --no-cache redis

COPY ./files/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis

EXPOSE 6379

LABEL description="redis"

USER redis

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
