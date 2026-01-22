#!/bin/sh

DB_PASSWORD=$(cat /run/secrets/db_password)

if [ -n "$WP_PORT" ]; then
    WP_URL="https://${DOMAIN_NAME}:${WP_PORT}"
else
    WP_URL="https://${DOMAIN_NAME}"
fi

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until nc -z -v -w30 $DB_HOST 3306
do
  echo "Waiting for database connection..."
  sleep 2
done
echo "MariaDB is ready!"

sleep 3

# Check if WordPress is already installed
if ! [ -e /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."

    mkdir -p /var/www/html
    cd /var/www/html

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar

    ./wp-cli.phar core download --allow-root

    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" --allow-root

    ./wp-cli.phar core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" --allow-root

    ./wp-cli.phar user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role="author" --allow-root

    # Disable email notifications (no mail server configured)
    echo "Disabling email notifications..."
    ./wp-cli.phar option update comments_notify 0 --allow-root
    ./wp-cli.phar option update moderation_notify 0 --allow-root

    # Fix permissions
    chown -R nobody:nobody /var/www/html/wp-content/
    chmod -R 755 /var/www/html/wp-content/

else
    echo "WordPress already installed."
fi

php-fpm83 -F # Start PHP-FPM in foreground
