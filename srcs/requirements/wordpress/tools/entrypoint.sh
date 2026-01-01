#!/bin/bash
set -e

# Read secrets from Docker secrets files
if [ -f /run/secrets/DB_PASSWORD ]; then
	DB_PASSWORD=$(cat /run/secrets/DB_PASSWORD)
	export DB_PASSWORD
fi

if [ -f /run/secrets/WP_ADMIN_PASSWORD ]; then
	WP_ADMIN_PASSWORD="$(cat /run/secrets/WP_ADMIN_PASSWORD)"
	export WP_ADMIN_PASSWORD
fi

# Check if WordPress is installed, if not download it
if [ ! -f /var/www/html/wp-settings.php ]; then
	echo "WordPress not found, downloading..."
	wget https://wordpress.org/latest.tar.gz
	tar -xzvf latest.tar.gz
	mv wordpress/* /var/www/html/
	rm -rf wordpress latest.tar.gz
	chown -R nobody:nobody /var/www/html
	chmod -R 755 /var/www/html
	echo "WordPress downloaded successfully"
fi

if [ "$ENV_FILE" != "1" ]; then
echo "Waiting for MariaDB..."
until nc -z "${DB_HOST}" 3306; do
  sleep 1
done

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Creating wp-config.php..."
	wp config create \
	--dbname="${DB_NAME}" \
	--dbuser="${DB_USER}" \
	--dbpass="${DB_PASSWORD}" \
	--dbhost="${DB_HOST}" \
	--allow-root
fi

if ! wp core is-installed --allow-root; then
	echo "Installing WordPress..."
	wp core install \
	--url="${WP_URL}" \
	--title="${WP_TITLE}" \
	--admin_user="${WP_ADMIN_USER}" \
	--admin_password="${WP_ADMIN_PASSWORD}" \
	--admin_email="${WP_ADMIN_EMAIL}" \
	--allow-root
fi
else
echo "ENV_FILE=1 → skipping DB and WP initialization"
fi


exec "$@"
