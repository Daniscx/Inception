#!/bin/bash

export MYSQL_PASSWORD="$(cat /run/secrets/MYSQL_PASSWORD)"
export WORDPRESS_USER_PASS="$(cat /run/secrets/WORDPRESS_USER_PASS)"
export WORDPRESS_ADMIN_PASS="$(cat /run/secrets/WORDPRESS_ADMIN_PASS)"
until mysqladmin ping \
    -h"$MYSQL_HOSTNAME" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    --silent
do
    echo "Esperando MariaDB..."
    sleep 2
done
echo "MariaDB está disponible."

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Instalando WordPress..."

    wp core download --allow-root

    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOSTNAME" \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="$WORDPRESS_ADMIN" \
        --admin_password="$WORDPRESS_ADMIN_PASS" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create \
        "$WORDPRESS_USER" \
        "$WORDPRESS_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_USER_PASS" \
        --allow-root

    wp theme install twentysixteen --activate --allow-root
fi

exec /usr/sbin/php-fpm8.2 -F