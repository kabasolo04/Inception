#!/bin/sh

set -e

# Read secrets from files
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Fix permissions for mounted volume
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql

mysql_install_db --user=mysql --ldata=/var/lib/mysql

mkdir -p /etc/mysql

cat <<EOF > /etc/mysql/init.sql
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
-- Create regular user for WordPress
CREATE OR REPLACE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

exec mysqld
