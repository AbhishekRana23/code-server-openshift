FROM ubuntu:18.04

ENV LANG=en_US.UTF-8 \
    # adding a sane default is needed since we're not erroring out via exec.
     CODER_PASSWORD="coder"

#Change this via --arg in Docker CLI
ARG CODER_VERSION=3.4.1

COPY exec /opt

RUN apt-get update && \
    apt-get install -y  \
      sudo \
      openssl \
      net-tools \
      git \
      locales \
      curl \
      dumb-init \
      wget && \
    locale-gen en_US.UTF-8 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    wget -O - https://github.com/cdr/code-server/releases/download/${CODER_VERSION}/code-server-${CODER_VERSION}-linux-x86_64.tar.gz | tar -xzv && \
    chmod -R 755 code-server-${CODER_VERSION}-linux-x86_64/code-server && \
    mv code-server-${CODER_VERSION}-linux-x86_64/code-server /usr/bin/ && \
    rm -rf code-server-${CODER_VERSION}-linux-x86_64 && \
    adduser --disabled-password --gecos '' coder  && \
    echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd;

RUN apt-get update 


WORKDIR /home/coder

USER root

RUN mkdir -p projects && mkdir -p certs && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    sudo chmod -R g+rw projects/ && \
    sudo chmod -R g+rw certs/ && \
    sudo chmod -R 755 /opt/exec;

VOLUME ["/home/coder/projects", "/home/coder/certs"];

EXPOSE 9000

CMD ["/opt/exec"]
