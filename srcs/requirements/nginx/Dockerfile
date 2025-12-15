FROM alpine:3.23

RUN apk update && \
	apk add nginx openssl && \
	apk add --no-cache bash

RUN mkdir -p /var/log/nginx /etc/nginx/ssl

# Self-signed cert for local/dev. For production, mount real certs to /etc/nginx/ssl.
RUN openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/private.key \
  -out /etc/nginx/ssl/certificate.crt \
  -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mukibrok.42.fr"

# Ship defaults; docker-compose bind-mounts can override conf.d at runtime.
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]