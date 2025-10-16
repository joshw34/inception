#!/bin/sh

set -e

if [ ! -f /etc/nginx/ssl/cert.crt ]; then
  mkdir -p /etc/nginx/ssl
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.key \
    -out /etc/nginx/ssl/cert.crt \
    -subj "/C=FR/ST=PACA/L=Nice/O=42/CN=$DOMAIN_NAME"
  echo "SSL certificate generated"
fi

sed -i "s/\${DOMAIN_NAME}/$DOMAIN_NAME/g" /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
