#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
  echo "Generating self-signed SSL certificate..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=TR/ST=Istanbul/L=Istanbul/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

echo "SSL certificate is ready."
exec nginx -g "daemon off;"
