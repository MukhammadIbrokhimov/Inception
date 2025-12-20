FROM alpine:3.23

WORKDIR /var/www/html

RUN apk update && apk add --no-cache \
	php82 \
	php82-fpm \
	php82-mysqli \
	php82-json \
	php82-curl \
	php82-dom \
	php82-gd \
	php82-exif \
	php82-fileinfo \
	php82-ftp \
	php82-mbstring \
	php82-openssl \
	php82-xml \
	php82-zip \
	php82-redis \
	wget \
	curl

RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	mv wordpress/* /var/www/html/ && \
	rm -rf wordpress latest.tar.gz wordpress

RUN chown -R nobody:nobody /var/www/html && \
	chmod -R 755 /var/www/html

RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf && \
	sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php82/php-fpm.d/www.conf

RUN wget https://githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm82", "-F"]

