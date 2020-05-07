#!/usr/bin/bash

systemctl start docker
docker run --rm --name Nginx -d \
        -p 8080:8080 \
        bitnami/nginx:latest