#!/bin/sh

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB..."
RETRIES=30
while [ $RETRIES -gt 0 ]; do
    if nc -z $MYSQL_HOST 3306 2>/dev/null; then
        echo "MariaDB port is open!"
        sleep 5
        break
    fi
    RETRIES=$((RETRIES - 1))
    echo "MariaDB not ready yet, waiting... ($RETRIES attempts left)"
    sleep 2
done

if [ $RETRIES -eq 0 ]; then
    echo "ERROR: MariaDB not ready in time"
    exit 1
fi

echo "MariaDB is ready"

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    echo "Creating second user..."
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
    
    echo "WordPress setup complete!"
fi

chown -R wp-data:wp-data /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm84 -F
