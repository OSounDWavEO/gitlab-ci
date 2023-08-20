#!/bin/sh
set -e
 
cat <<EOT > Dockerfile
FROM ${RUNNER_IMAGE}

COPY files/default.conf /etc/nginx/conf.d/default.conf

COPY ${OUTPUT} /usr/share/nginx/html
EOT
