FROM alpine:3.22.2

RUN apk update && \
    apk add --no-cache php84 php84-mysqli php84-common php84-session wget

RUN mkdir -p /var/www/html && \
    wget -O /var/www/html/index.php https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-mysql-en.php

WORKDIR /var/www/html

EXPOSE 8080

CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
