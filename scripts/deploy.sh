#!/bin/bash -xe

PROFILE=${1:-standard}
export PATH="$PWD/vendor/bin:$PATH"

pushd scripts/local-docker
docker-compose build --pull
docker-compose pull
docker-compose up -d
popd
composer install
composer update
drush -y rsync . @docker.local
drush -y @docker.local si --db-url=mysql://drupal:drupal@drupaldb:3306/drupal --site-name="$PROFILE site" $PROFILE
drush -y @docker.local en devel devel_php devel_generate easy_install php pacifica_uploader
drush @docker.local uli
