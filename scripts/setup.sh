#!/bin/bash -xe

PACIFICA_VERSION="v1.0.0"
if [[ ! -d scripts/pacifica/.git ]] ; then
  git clone https://github.com/pacifica/pacifica.git scripts/pacifica
fi
pushd scripts/pacifica
git checkout ${PACIFICA_VERSION}
DOCKER_COMPOSE_CMD="docker-compose -f docker-compose.yml -f ../pacifica-docker-compose.override.yml"
$DOCKER_COMPOSE_CMD pull
$DOCKER_COMPOSE_CMD build --pull
$DOCKER_COMPOSE_CMD up -d
MAX_TRIES=60
HTTP_CODE=$(curl -sL -w "%{http_code}\\n" localhost:8121/keys -o /dev/null || true)
while [[ $HTTP_CODE != 200 && $MAX_TRIES > 0 ]] ; do
  sleep 1
  HTTP_CODE=$(curl -sL -w "%{http_code}\\n" localhost:8121/keys -o /dev/null || true)
  MAX_TRIES=$(( MAX_TRIES - 1 ))
done
docker-compose exec metadataserver python /usr/src/app/tests/test_files/loadit_test.py
popd
