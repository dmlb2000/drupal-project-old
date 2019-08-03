#!/bin/bash -xe

RUN_COMPOSER=${RUN_COMPOSER:-$1}
PROFILE=${PROFILE:-standard}
export PATH="$PWD/vendor/bin:$PATH"
if [[ ${RUN_COMPOSER} ]] ; then
  composer install
  composer update
fi
drush -y @docker.local ssh -- rm -rf docroot/modules/contrib
drush -y rsync . @docker.local
drush -y @docker.local si --db-url=mysql://drupal:drupal@drupaldb:3306/drupal --site-name="$PROFILE site" $PROFILE
drush -y @docker.local en devel devel_php devel_generate easy_install php pacifica_uploader pacifica_synch config_inspector pacifica_migrate migrate_tools
drush -y @docker.local cset pacifica_migrate.settings pacifica_migrate.database_settings.host metadatadb
#drush -y @docker.local cset pacifica_synch.settings pacifica_synch.enabled true
#drush -y @docker.local cset pacifica_synch.settings pacifica_synch.metadata.host metadataserver
#drush -y @docker.local cset pacifica_synch.settings pacifica_synch.amqp.host drupalamqp
drush @docker.local migrate:import --tag Pacifica
drush @docker.local uli
