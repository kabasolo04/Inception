#!/bin/sh

# Wait for MariaDB to be ready
#until mysqladmin ping -h "$WORDPRESS_DB_HOST" --silent; do
#    echo "Waiting for MariaDB..."
#    sleep 1
#done

sleep 3
# Check if WordPress is already installed
if ! [ -e /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."

    mkdir -p /var/www/html
    
    cd /var/www/html

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    # Download WordPress core files
    ./wp-cli.phar core download --allow-root

    # Create wp-config.php with DB credentials
    ./wp-cli.phar config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root

    # Install WordPress
    ./wp-cli.phar core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root

    # Clean up
    rm wp-cli.phar
else
    echo "WordPress already installed."
fi

# Start PHP-FPM in foreground
php-fpm83 -F
