#!/bin/bash -xe

RUN_COMPOSER=${RUN_COMPOSER:-$1}
PROFILE=${PROFILE:-standard}
export PATH="$PWD/vendor/bin:$PATH"
if [[ ${RUN_COMPOSER} ]] ; then
  composer install
  composer update
fi
drush -y rsync . @docker.local
drush -y @docker.local si --db-url=mysql://drupal:drupal@drupaldb:3306/drupal --site-name="$PROFILE site" $PROFILE
drush -y @docker.local en devel devel_php devel_generate easy_install php pacifica_uploader pacifica_synch config_inspector
drush -y @docker.local cset pacifica_synch.settings pacifica_synch.enabled true
drush -y @docker.local cset pacifica_synch.settings pacifica_synch.metadata.host metadataserver
drush -y @docker.local cset pacifica_synch.settings pacifica_synch.amqp.host drupalamqp
drush @docker.local uli
