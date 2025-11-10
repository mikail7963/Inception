#!/bin/sh
set -e

cd /var/www/html

echo "MariaDB bekleniyor..."
until mariadb -h mariadb -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done
echo "MariaDB hazır!"

if [ ! -f wp-config.php ]; then
  echo "WordPress indiriliyor..."
  wp core download --allow-root
  
  echo "wp-config.php oluşturuluyor..."
  wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASSWORD}" \
    --dbhost="mariadb:3306" \
    --allow-root
  
  echo "WordPress kurulumu yapılıyor..."
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --allow-root
  
fi

chown -R www-data:www-data /var/www/html

echo "WordPress hazır."
exec /usr/sbin/php-fpm8.2 -F
