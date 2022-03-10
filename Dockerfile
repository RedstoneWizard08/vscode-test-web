FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

ENV NVM_DIR=/usr/lib/nvm

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install bash \
    curl git wget tar libssl-dev && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    echo "${NVM_DIR}/nvm.sh" >> "${HOME}/.bashrc" && \
    . "${NVM_DIR}/nvm.sh" && \
    nvm install 16 && \
    nvm use 16 && \
    npm install --global yarn@latest npm@latest && \
    git clone https://github.com/microsoft/vscode-test-web.git && \
    cd vscode-test-web && \
    yarn install && \
    yarn install-extensions && \
    yarn compile