#!/bin/bash -xe

PROFILE=${1:-standard}
PACIFICA_VERSION="v1.0.0"

if [[ ! -d scripts/pacifica/.git ]] ; then
  git clone https://github.com/pacifica/pacifica.git scripts/pacifica
fi
pushd scripts/pacifica
git fetch --all
git checkout ${PACIFICA_VERSION}
DOCKER_COMPOSE_CMD="docker-compose -f docker-compose.yml -f ../pacifica-docker-compose.override.yml"
$DOCKER_COMPOSE_CMD pull
$DOCKER_COMPOSE_CMD build --pull
$DOCKER_COMPOSE_CMD up -d metadataserver mgmt policyserver
popd
pushd scripts/local-docker
docker-compose build --pull
docker-compose pull
docker-compose up -d
popd
sleep 10
pushd scripts/pacifica
MAX_TRIES=60
HTTP_CODE=$(curl -sL -w "%{http_code}\\n" localhost:8121/keys -o /dev/null || true)
while [[ $HTTP_CODE != 200 && $MAX_TRIES > 0 ]] ; do
  sleep 1
  HTTP_CODE=$(curl -sL -w "%{http_code}\\n" localhost:8121/keys -o /dev/null || true)
  MAX_TRIES=$(( MAX_TRIES - 1 ))
done
$DOCKER_COMPOSE_CMD exec metadataserver python /usr/src/app/tests/test_files/loadit_test.py
$DOCKER_COMPOSE_CMD exec policyserver python -m pip install 'pacifica-metadata==0.10.3'
$DOCKER_COMPOSE_CMD exec policyserver python /usr/src/app/tests/test_files/loadit_test.py
popd
