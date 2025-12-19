FROM alpine:3.23

# Set working directory
WORKDIR /etc/nginx

# Install packages and setup in a single layer
RUN apk add --no-cache \
        nginx \
        openssl \
    && mkdir -p \
        /var/www/html \
        /var/log/nginx \
        /etc/nginx/ssl \
        /run/nginx \
    && openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/private.key \
        -out /etc/nginx/ssl/certificate.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mukibrok.42.fr" \
    && chown -R nginx:nginx \
        /var/www/html \
        /var/log/nginx \
        /etc/nginx/ssl \
        /run/nginx \
    && chmod 600 /etc/nginx/ssl/private.key \
    && chmod 644 /etc/nginx/ssl/certificate.crt

# Copy configuration files
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/default.conf /etc/nginx/http.d/default.conf

# Expose HTTPS port
EXPOSE 443

# Health check (optional but good practice)
#HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#    CMD wget --no-verbose --tries=1 --spider https://localhost:443/ || exit 1

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]