FROM alpine:3.23

RUN apk update && apk add --no-cache mariadb mariadb-client \
	&& rm -rf /var/cache/apk/*

COPY ./requirements/mariadb/conf/50-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY ./requirements/mariadb/tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && \
	mkdir -p /var/run/mysqld /var/log/mysql && \
	chown -R mysql:mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/lib/mysql && \
	chown -R mysql:mysql /var/log/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mariadbd"]
