#!/bin/bash -xe

pushd scripts/local-docker
docker-compose down --volumes
popd
