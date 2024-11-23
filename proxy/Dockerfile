FROM nginx:1.23.0

LABEL org.opencontainers.image.authors="Levente F. <thebe14@proton.me>"

# Build-time environment variables specified by docker-compose.yml / .env
ARG BRIDGE_EMAIL
ARG BRIDGE_DOMAIN
ARG LETSENCRYPT_DIR
ARG LETSENCRYPT_DRYRUN

# Run-time environment variables
ENV EMAIL ${BRIDGE_EMAIL}
ENV DOMAIN ${BRIDGE_DOMAIN}
ENV SSL_CERT_OPTIONS=${SSL_CERT_OPTIONS:-}
ENV SSL_CERT_RENEW_INTERVAL=${SSL_CERT_RENEW_INTERVAL:-12h}
ENV LETSENCRYPT_DIR=${LETSENCRYPT_DIR:-/etc/letsencrypt}
ENV LETSENCRYPT_DRYRUN=${LETSENCRYPT_DRYRUN:-}
ENV NGINX_DIR=/etc/nginx

# Install certbot and openssl
# Using inotifywait to watch our certificates and trigger actions on change
RUN apt-get -q -y update && \
    apt-get -q -y install inotify-tools openssl certbot gettext-base vim && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

# Configure website
COPY nginx.conf $NGINX_DIR/nginx.conf
COPY default.conf $NGINX_DIR/conf.d/default.conf.template
RUN envsubst '${DOMAIN}' < $NGINX_DIR/conf.d/default.conf.template > $NGINX_DIR/conf.d/default.conf && \
    rm -f $NGINX_DIR/conf.d/default.conf.template && \
    rm -f $NGINX_DIR/sites-enabled/default && \
    mkdir -p /var/cache/nginx/proxycache && \
    mkdir -p /var/cache/nginx/proxytemp

# Configure entrypoint
WORKDIR /opt
COPY cert-entrypoint.sh entrypoint.sh
COPY cert-request.sh request.sh
COPY health-check.sh status.sh

RUN chmod a+x entrypoint.sh && \
    chmod a+x request.sh && \
    chmod a+x status.sh

EXPOSE 80 
#143 25

ENTRYPOINT ["./entrypoint.sh"]
