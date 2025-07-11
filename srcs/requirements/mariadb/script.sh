#!/bin/sh

# Initialize database if not already
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB database..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background
echo "Starting MariaDB..."
mysqld --user=mysql --datadir=/var/lib/mysql &
pid=$!

# Wait for MariaDB to be ready
until mysqladmin ping --silent; do
    echo "Waiting for MariaDB..."
    sleep 1
done

# Run init.sql once
if [ -f /init.sql ]; then
    echo "Running init.sql..."
    mysql < /init.sql
    rm /init.sql
fi

# Wait on the backgrounded MariaDB process
wait "$pid"
