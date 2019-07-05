#!/bin/bash -e

PROFILE=${1:-dmlb2000}
export PATH="$PWD/vendor/bin:$PATH"

pushd scripts/local-docker
docker-compose build --pull
docker-compose pull
docker-compose up -d
popd
composer install
drush -y rsync . @docker.local
drush -y @docker.local si --db-url=mysql://drupal:drupal@drupaldb:3306/drupal --site-name="$PROFILE site" $PROFILE
