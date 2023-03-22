#!/bin/sh
set -e
 
cat <<EOT > Dockerfile
FROM nginx::latest

COPY files/default.conf /etc/nginx/conf.d/default.conf

COPY $STATIC_DIR /usr/share/nginx/html
EOT
