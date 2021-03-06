#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the docker-laravel image
# ------------------------------------------------------------------------------

apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------

apt-get -y install nginx
cp /provision/service/nginx.conf /etc/supervisord/nginx.conf

#configuration files
cp /provision/conf/nginx/development /etc/nginx/sites-available/default
cp /provision/conf/nginx/production.template /etc/nginx/sites-available/production.template

# disable 'daemonize' in nginx (because we use supervisor instead)
echo "daemon off;" >> /etc/nginx/nginx.conf

# ------------------------------------------------------------------------------
# Software properties
# ------------------------------------------------------------------------------

apt-get -y install software-properties-common

# ------------------------------------------------------------------------------
# PHP7
# ------------------------------------------------------------------------------

# add repository

add-apt-repository ppa:ondrej/php -y &> /dev/null
apt-get update

# install PHP
apt-get -y install php7.2-fpm php7.2-cli
cp /provision/service/php-fpm.conf /etc/supervisord/php-fpm.conf
mkdir -p /var/run/php

apt-get -y install php7.2-mbstring php7.2-xml php7.2-mysqlnd php7.2-curl php7.2-xml php7.2-common php7.2-gd php7.2-bz2

# disable 'daemonize' in php-fpm (because we use supervisor instead)
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf

# ------------------------------------------------------------------------------
# XDebug (installed but not enabled)
# ------------------------------------------------------------------------------

apt-get -y install php7.2-xdebug
phpdismod xdebug
phpdismod -s cli xdebug

# ------------------------------------------------------------------------------
# Composer PHP dependency manager
# ------------------------------------------------------------------------------

curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm ./composer-setup.php

# ------------------------------------------------------------------------------
# MariaDB server
# ------------------------------------------------------------------------------

# install MariaDB client and server
apt-get -y install mariadb-client
apt-get -y install mariadb-server pwgen
cp /provision/service/mariadb.conf /etc/supervisord/mariadb.conf

# MariaDB seems to have problems starting if these permissions are not set:
mkdir -p /var/run/mysqld
chmod 777 /var/run/mysqld

# ------------------------------------------------------------------------------
# Beanstalkd task queue
# ------------------------------------------------------------------------------

apt-get -y install beanstalkd
cp /provision/service/beanstalkd.conf /etc/supervisord/beanstalkd.conf
cp /provision/service/queue.conf /etc/supervisord/queue.conf

# ------------------------------------------------------------------------------
# Node and npm
# ------------------------------------------------------------------------------

curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
chmod +x nodesource_setup.sh
./nodesource_setup.sh
apt-get -y install nodejs
apt-get -y install build-essential
rm ./nodesource_setup.sh
npm install -g npm@latest

# ------------------------------------------------------------------------------
# Wkhtmltopdf
#
# Libxrender is used for headless PDF generation on servers without a GUI
# ------------------------------------------------------------------------------

apt-get -y install libxrender1
curl -sL http://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -o wkhtmltopdf.tar.xz
tar xf wkhtmltopdf.tar.xz
mv wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
rm -rf ./wkhtmlto*

# ------------------------------------------------------------------------------
# PhantomJS (headless browser)
# ------------------------------------------------------------------------------

curl -sL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -o phantomjs.tar.bz2
tar xf phantomjs.tar.bz2
mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin/phantomjs
rm -rf ./phantomjs*

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision
