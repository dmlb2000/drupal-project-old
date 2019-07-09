from drupal:8-apache

run export DEBIAN_FRONTEND="noninteractive" ; \
    apt-get update; \
    apt-get install -y apt-file apt-utils dialog curl; \
    apt-get install -y systemd-container rsyslog openssh-server openssh-client vim \
    zlib1g-dev memcached rsync libmemcached-dev git mariadb-client; \
    rm -rf /var/lib/apt/lists/*
copy uploads.ini /usr/local/etc/php/conf.d/uploads.ini
arg PHP_MEMCACHED_VER=3.1.3
run mkdir -p /usr/src/php/ext
run curl -L https://github.com/php-memcached-dev/php-memcached/archive/v${PHP_MEMCACHED_VER}.tar.gz | tar -C /usr/src/php/ext -xzf -; mv /usr/src/php/ext/php-memcached-${PHP_MEMCACHED_VER} /usr/src/php/ext/memcached
run docker-php-ext-install bcmath sockets
run docker-php-ext-configure memcached --with-zlib-dir=/usr; \
    docker-php-ext-install memcached
run rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl*
volume /sys/fs/cgroup
run rm -f /var/log/apache2/access.log /var/log/apache2/error.log /var/log/apache2/other_vhosts_access.log
run systemctl enable apache2 ssh rsyslog memcached
run ln -sf /lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service
run sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/drupal/public_html|' /etc/apache2/sites-available/000-default.conf
run useradd -g www-data -s /bin/bash -d /var/www/drupal -m drupal
run mkdir /var/www/drupal/.ssh
run ln -s site/docroot /var/www/drupal/public_html
copy authorized_keys /var/www/drupal/.ssh/authorized_keys
run chmod og-rwx /var/www/drupal/.ssh /var/www/drupal/.ssh/authorized_keys
run chown drupal:www-data -R /var/www/drupal
workdir /
entrypoint ["/lib/systemd/systemd"]
