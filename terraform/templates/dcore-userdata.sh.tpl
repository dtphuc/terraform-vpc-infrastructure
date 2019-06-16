#!/usr/bin/bash

systemctl start docker

# docker run --rm --name DCore -d \
#         -p 8090:8090 \
#         -p 40000:40000 \
#         --mount type=bind,src=${mount_dir},dst=/root/.decent/data \
#         decentnetwork/dcore.ubuntu

docker run --rm --name Nginx -d \
        -p 8090:8080 \
        bitnami/nginx:latest