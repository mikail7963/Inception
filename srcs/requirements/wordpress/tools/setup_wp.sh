#!/bin/sh
set -e

cd /var/www/html

echo "Waiting for MariaDB..."
until mariadb -h mariadb -u"${DB_USER}" -p"$(cat /run/secrets/db_password)" -e "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done
echo "MariaDB is ready!"

if [ ! -f wp-config.php ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root
  
  echo "Creating wp-config.php..."
  wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="$(cat /run/secrets/db_password)" \
    --dbhost="mariadb:3306" \
    --allow-root
  
  echo "Installing WordPress..."
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="$(cat /run/secrets/wp_admin_password)" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --allow-root
  
  echo "Creating second user..."
  wp user create \
    "${WP_USER}" \
    "${WP_USER_EMAIL}" \
    --role="author" \
    --user_pass="$(cat /run/secrets/wp_user_password)" \
    --allow-root
  
fi

chown -R www-data:www-data /var/www/html

echo "WordPress is ready."
exec /usr/sbin/php-fpm8.2 -F
