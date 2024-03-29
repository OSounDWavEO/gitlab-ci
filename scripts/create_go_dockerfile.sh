#!/bin/sh
set -e

cat <<EOT > Dockerfile
FROM ${RUNNER_IMAGE}

WORKDIR /opt/app
COPY ${OUTPUT} /opt/app/

CMD ["./${CI_PROJECT_NAME}"]
EOT
