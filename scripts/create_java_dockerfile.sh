#!/bin/sh
set -e

cat <<EOT > Dockerfile
FROM ${RUNNER_IMAGE}

WORKDIR /opt/app
COPY ${OUTPUT} /opt/app/

ENTRYPOINT ["java","-jar","/opt/app/${CI_PROJECT_NAME}-1.0.0-SNAPSHOT.jar"]  
EOT
