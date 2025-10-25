FROM alpine:3.22.2

RUN apk update && \
    apk add --no-cache nginx openssl apache2-utils

COPY ./files/nginx.conf /etc/nginx/nginx.conf
COPY ./files/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

LABEL description="nginx"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
