FROM alpine:3.23

WORKDIR /var/www/html

RUN apk update && apk add --no-cache \
	php83 \
	php83-fpm \
	php83-mysqli \
	php83-json \
	php83-curl \
	php83-dom \
	php83-gd \
	php83-exif \
	php83-fileinfo \
	php83-ftp \
	php83-mbstring \
	php83-openssl \
	php83-xml \
	php83-zip \
	php83-redis \
	wget \
	curl \
	bash

RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	mv wordpress/* /var/www/html/ && \
	rm -rf wordpress latest.tar.gz wordpress

RUN chown -R nobody:nobody /var/www/html && \
	chmod -R 755 /var/www/html

RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf && \
	sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php83/php-fpm.d/www.conf

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

COPY requirements/wordpress/tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm83", "-F"]

