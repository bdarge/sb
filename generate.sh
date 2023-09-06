#!/bin/bash

mkdir -p ssl

openssl req \
    -newkey rsa:2048 \
    -x509 \
    -nodes \
    -keyout ssl/server.key \
    -new \
    -out ssl/server.crt \
    -config ./openssl-custom.cnf \
    -sha256 \
    -days 365

