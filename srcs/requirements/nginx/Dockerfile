FROM alpine:3.23

RUN apk update && \
	apk add nginx openssl && \
	apk add --no-cache bash

RUN mkdir -p /var/www/html \
	mkdir -p /var/log/nginx \
	mkdir -p /etc/nginx/ssl 
RUN openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout private.key \
  -out certificate.crt \
  -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mukibrok.42.fr"

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /var/www/html/index.html

CMD ["nginx", "-g", "daemon off;"]