#!/bin/sh
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

tempfile=$(mktemp)
cat << SQL > "$tempfile"
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.global_priv WHERE User='';
DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

/usr/sbin/mariadbd --user=mysql --bootstrap < "$tempfile"
rm -f "$tempfile"

echo "MariaDB is ready."
exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0
