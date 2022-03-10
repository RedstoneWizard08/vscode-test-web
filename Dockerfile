FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

ENV NVM_DIR=/usr/lib/nvm
ENV VSCODE_PATH=/usr/lib/vscode

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install bash \
    curl git wget tar libssl-dev && \
    mkdir -p "${NVM_DIR}" && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    echo "${NVM_DIR}/nvm.sh" >> "${HOME}/.bashrc" && \
    . "${NVM_DIR}/nvm.sh" && \
    nvm install 16 && \
    nvm use 16 && \
    npm install --global yarn@latest npm@latest && \
    git clone https://github.com/RedstoneWizard08/vscode-test-web.git "${VSCODE_PATH}" && \
    cd "${VSCODE_PATH}" && \
    yarn install && \
    yarn install-extensions && \
    yarn compile && \
    mkdir -p "${NVM_DIR}/default_bin" && \
    ln -s "$(which node)" "${NVM_DIR}/default_bin/node"

CMD [ "/usr/lib/nvm/default_bin/node", "/usr/lib/vscode", "--host", \
      "0.0.0.0", "--port", "3000", "--headless", "--browser", "none", \
      "--quality", "stable" ]