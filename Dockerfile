FROM ubuntu:xenial

# Project directory
WORKDIR /src/blockstack-browser

# Update apt and install wget
RUN apt-get update && apt-get install -y wget curl apt-utils git

# Install node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get install -y nodejs

# Install cors-proxy
RUN npm install -g corsproxy

# Alias the cors-proxy
RUN ln /usr/bin/corsproxy /usr/bin/blockstack-cors-proxy

# Install dependencies at specified branch
WORKDIR /src/blockstack-deps
RUN git clone https://github.com/kantai/blockstack-storage-js.git -b develop-multiplayer-storage
RUN git clone https://github.com/blockstack/blockstack.js.git -b develop-keyfile
RUN cd blockstack-storage-js && npm i && npm run compile
RUN cd blockstack.js && npm install ../blockstack-storage-js/ && npm i && npm run compile

# Copy files into container
WORKDIR /src/blockstack-browser

COPY . .

RUN npm install ../blockstack-deps/blockstack-storage-js
RUN npm install ../blockstack-deps/blockstack.js

# Install dependencies
RUN npm install

# Build production assets
RUN /src/blockstack-browser/node_modules/.bin/gulp prod

# Setup script to run browser
RUN echo '#!/bin/bash' >> /src/blockstack-browser/blockstack-browser
RUN echo 'node /src/blockstack-browser/native/blockstackProxy.js 8888 /src/blockstack-browser/build' >> /src/blockstack-browser/blockstack-browser
RUN chmod +x /src/blockstack-browser/blockstack-browser
RUN ln /src/blockstack-browser/blockstack-browser /usr/bin/blockstack-browser