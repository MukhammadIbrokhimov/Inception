FROM alpine:3.23

WORKDIR /var/www/html

RUN apk update && apk add --no-cache \
	php \
	php-fpm \
	php-mysqli \
	php-json \
	php-curl \
	php-dom \
	php-gd \
	php-exif \
	php-fileinfo \
	php-ftp \
	php-mbstring \
	php-openssl \
	php-xml \
	php-zip \
	php-redis \
	php-phar \
	mariadb-client \
	wget \
	curl \
	bash \
	netcat-openbsd

RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	mv wordpress/* /var/www/html/ && \
	rm -rf wordpress latest.tar.gz wordpress

RUN chown -R nobody:nobody /var/www/html && \
	chmod -R 755 /var/www/html

RUN set -eux; \
	CONF="$(find /etc -type f -path '*/php*/php-fpm.d/www.conf' -print -quit)"; \
	echo "Using PHP-FPM config: $CONF"; \
	ln -s /usr/sbin/php-fpm* /usr/bin/php-fpm; \ 
	sed -i 's|^listen = .*|listen = 9000|' "$CONF"; \
	sed -i 's|^;daemonize = yes|daemonize = no|' "$CONF"

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

COPY requirements/wordpress/tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]

