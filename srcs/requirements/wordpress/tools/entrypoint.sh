#!/bin/sh
set -e

if [ "$ENV_FILE" != "1" ]; then
echo "Waiting for MariaDB..."
until mysqladmin ping \
	-h"$DB_HOST" \
	-u"$DB_USER" \
	-p"$DB_PASSWORD" \
	--silent; do
	sleep 1
done

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Creating wp-config.php..."
	wp config create \
	--dbname="$DB_NAME" \
	--dbuser="$DB_USER" \
	--dbpass="$DB_PASSWORD" \
	--dbhost="$DB_HOST" \
	--allow-root
fi

if ! wp core is-installed --allow-root; then
	echo "Installing WordPress..."
	wp core install \
	--url="$WP_URL" \
	--title="$WP_TITLE" \
	--admin_user="$WP_ADMIN_USER" \
	--admin_password="$WP_ADMIN_PASSWORD" \
	--admin_email="$WP_ADMIN_EMAIL" \
	--allow-root
fi
else
echo "ENV_FILE=1 → skipping DB and WP initialization"
fi

exec "$@"
