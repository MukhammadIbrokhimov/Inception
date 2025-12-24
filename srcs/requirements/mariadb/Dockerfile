FROM alpine:3.23

RUN apk update && apk add --no-cache \
	mariadb-server \
	mariadb-client \
	&& rm -rf /var/lib/apk/lists/*

COPY ./requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./requirements/mariadb/tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /etc/mysql/mariadb.conf.d

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mysqld"]
