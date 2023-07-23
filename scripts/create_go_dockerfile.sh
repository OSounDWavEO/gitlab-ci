#!/bin/sh
set -e

cat <<EOT > Dockerfile
FROM ${RUNNER_IMAGE}

WORKDIR /data/app
COPY bin /data/app/

CMD ["./${CI_PROJECT_NAME}"]
EOT
