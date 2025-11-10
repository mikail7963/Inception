#!/bin/sh
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "MariaDB veri dizini başlatılıyor..."
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
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

/usr/sbin/mariadbd --user=mysql --bootstrap < "$tempfile"
rm -f "$tempfile"

echo "MariaDB hazır."
exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0
