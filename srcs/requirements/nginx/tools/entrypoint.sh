#!/bin/sh

CERT=/etc/nginx/ssl/inception.crt
KEY=/etc/nginx/ssl/inception.key

mkdir -p /etc/nginx/ssl

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
  openssl req -x509 -nodes \
    -newkey rsa:4096 \
    -days 365 \
    -keyout "$KEY" \
    -out "$CERT" \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

exec nginx -g 'daemon off;'
