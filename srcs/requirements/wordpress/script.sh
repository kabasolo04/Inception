#!/bin/sh

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/db_root_password)

sleep 3
# Check if WordPress is already installed
if ! [ -e /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."

    mkdir -p /var/www/html
    cd /var/www/html

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar

    ./wp-cli.phar core download --allow-root

    ./wp-cli.phar config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost=mariadb --allow-root

    ./wp-cli.phar core install --url="https://kabasolo.42.fr" --title="mySite" --admin_user="koldobaik" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="koldobaik@gmail.com" --allow-root

    ./wp-cli.phar user create "$WP_USER_NAME" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role="$WP_USER_ROLE" --allow-root

else
    echo "WordPress already installed."
fi

# Start PHP-FPM in foreground
php-fpm83 -F
