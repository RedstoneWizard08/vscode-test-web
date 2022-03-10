FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

ENV VSCODE_PATH=/usr/lib/vscode

ENV NODE_DIRECTORY="/usr/lib/node"
ENV NODE_VERSION="16.14.0"
ENV NODE_DOWNLOAD_PREFIX="https://nodejs.org/dist/v"
ENV NODE_DOWNLOAD_MID="/"
ENV NODE_PACKAGE_PREFIX="node-v"
ENV NODE_PACKAGE_MID="-linux-"
ENV NODE_PACKAGE_SUFFIX=".tar.xz"
ENV NODE_TAR_FLAGS="xvf"
# zxvf for tar.gz files, zxf for non-verbose tar.gz, xf for non-verbose tar.xz

SHELL [ "/bin/bash", "-c" ]

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    bash curl git tar \
    xz-utils libatomic1 && \
    echo "Checking CPU architecture..." && \
    export DPKG_ARCH="$(dpkg --print-architecture)" && \
    case "${DPKG_ARCH}" in \
    arm64) export NODE_ARCH="arm64" ;; \
    armhf) export NODE_ARCH="armv7l" ;; \
    ppc64el) export NODE_ARCH="ppc64le" ;; \
    s390x) export NODE_ARCH="s390x" ;; \
    amd64) export NODE_ARCH="x64" ;; \
    *) { echo "Unsupported architecture. Exiting..."; exit 1; } ;; esac && \
    echo "Downloading node..." && \
    curl -fsSLo "/${NODE_PACKAGE_PREFIX}${NODE_VERSION}${NODE_PACKAGE_MID}${NODE_ARCH}${NODE_PACKAGE_SUFFIX}" \
    "${NODE_DOWNLOAD_PREFIX}${NODE_VERSION}${NODE_DOWNLOAD_MID}${NODE_PACKAGE_PREFIX}${NODE_VERSION}${NODE_PACKAGE_MID}${NODE_ARCH}${NODE_PACKAGE_SUFFIX}" && \
    if [[ -d "${NODE_DIRECTORY}" ]]; then { echo "Removing old install..."; rm -r "${NODE_DIRECTORY}"; }; fi && \
    echo "Creating directories..." && \
    mkdir -p "${NODE_DIRECTORY}" && \
    echo "Extracting node..." && \
    tar ${NODE_TAR_FLAGS} "/${NODE_PACKAGE_PREFIX}${NODE_VERSION}${NODE_PACKAGE_MID}${NODE_ARCH}${NODE_PACKAGE_SUFFIX}" -C "${NODE_DIRECTORY}" && \
    echo "Cleaning up..." && \
    rm "/${NODE_PACKAGE_PREFIX}${NODE_VERSION}${NODE_PACKAGE_MID}${NODE_ARCH}${NODE_PACKAGE_SUFFIX}" && \
    mv -v ${NODE_DIRECTORY}/${NODE_PACKAGE_PREFIX}${NODE_VERSION}${NODE_PACKAGE_MID}${NODE_ARCH}/* "${NODE_DIRECTORY}" && \
    rmdir "${NODE_DIRECTORY}/${NODE_PACKAGE_PREFIX}${NODE_VERSION}${NODE_PACKAGE_MID}${NODE_ARCH}" && \
    if [[ -f "/usr/local/bin/node" ]]; then { echo "Removing old node..."; rm "/usr/local/bin/node"; }; fi && \
    if [[ -f "/usr/local/bin/npm" ]]; then { echo "Removing old npm..."; rm "/usr/local/bin/npm"; }; fi && \
    if [[ -f "/usr/local/bin/npx" ]]; then { echo "Removing old npx..."; rm "/usr/local/bin/npx"; }; fi && \
    if [[ -f "/usr/local/bin/corepack" ]]; then { echo "Removing old corepack..."; rm "/usr/local/bin/corepack"; }; fi && \
    if [[ -f "/usr/local/bin/yarn" ]]; then { echo "Removing old yarn..."; rm "/usr/local/bin/yarn"; }; fi && \
    if [[ -f "/usr/local/bin/yarnpkg" ]]; then { echo "Removing old yarnpkg..."; rm "/usr/local/bin/yarnpkg"; }; fi && \
    echo "Creating symlinks..." && \
    ln -s "${NODE_DIRECTORY}/bin/node" "/usr/local/bin/node" && \
    ln -s "${NODE_DIRECTORY}/bin/npm" "/usr/local/bin/npm" && \
    ln -s "${NODE_DIRECTORY}/bin/npx" "/usr/local/bin/npx" && \
    ln -s "${NODE_DIRECTORY}/bin/corepack" "/usr/local/bin/corepack" && \
    echo "Installing dependencies..." && \
    npm install --global yarn@latest npm@latest && \
    ln -s "${NODE_DIRECTORY}/bin/yarn" "/usr/local/bin/yarn" && \
    ln -s "${NODE_DIRECTORY}/bin/yarnpkg" "/usr/local/bin/yarnpkg"

RUN git clone https://github.com/RedstoneWizard08/vscode-test-web.git "${VSCODE_PATH}" && \
    cd "${VSCODE_PATH}" && \
    yarn install && \
    yarn install-extensions && \
    yarn compile && \
    ln -s "$(which node)" "/node" && \
    node . --downloadOnly true --quality stable

WORKDIR "/usr/lib/vscode"

CMD [ "/node", "/usr/lib/vscode", "--host", \
      "0.0.0.0", "--port", "3000", "--headless", "--browser", "none", \
      "--quality", "stable" ]