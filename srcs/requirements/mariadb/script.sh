#!/bin/sh

set -e

# Read secrets from files
DB_PASSWORD=$(cat /run/secrets/db_password)

mysql_install_db --user=mysql --ldata=/var/lib/mysql

mkdir -p /etc/mysql

cat <<EOF > /etc/mysql/init.sql
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE OR REPLACE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

exec mysqld
