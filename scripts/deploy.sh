#!/bin/bash -e

PROFILE=${1:-dmlb2000}

pushd scripts/local-docker
docker-compose build --pull
docker-compose pull
docker-compose up -d
popd
echo $PROFILE
