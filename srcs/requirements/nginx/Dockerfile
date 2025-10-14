#Penulatimate version as of 13/10/25
FROM alpine:3.22.2

ARG DOMAIN_NAME

COPY ./files/setup_ssl.sh /usr/local/bin/setup_ssl.sh

RUN apk update && \
    apk add --no-cache nginx openssl && \
    chmod +x /usr/local/bin/setup_ssl.sh && \
    /usr/local/bin/setup_ssl.sh

COPY ./files/nginx.conf /etc/nginx/nginx.conf

RUN sed -i "s/\${DOMAIN_NAME}/$DOMAIN_NAME/g" /etc/nginx/nginx.conf

EXPOSE 443

LABEL description="nginx"

CMD ["nginx", "-g", "daemon off;"]
