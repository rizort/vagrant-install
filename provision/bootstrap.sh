#!/bin/bash
#

function message() {
    echo "------------------------------------"
    echo "$1"
    echo "------------------------------------"
}

message 'ADD SWAP'

sudo /bin/dd if=/dev/zero of=/swapfile bs=1G count=1
sudo chmod 600 /swapfile
sudo /sbin/mkswap /swapfile
sudo /sbin/swapon /swapfile

message 'INSTALL UTILS'

sudo apt-get install htop nano screenfetch zip unzip net-tools

message 'ADD REPOS'

# nginx
sudo echo '
deb http://nginx.org/packages/debian/ stretch nginx
deb-src http://nginx.org/packages/debian/ stretch nginx
' >> /etc/apt/sources.list
cd /tmp/ && sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key

# php
sudo apt-get -y install apt-transport-https ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee --append /etc/apt/sources.list.d/php.list

sudo apt-get update

message 'INSTALL NGINX'

sudo apt-get -y install nginx
usermod -G www-data vagrant

sudo rm /etc/nginx/conf.d/default.conf
sudo cp -f /vagrant/provision/config/nginx.conf /etc/nginx/nginx.conf
sudo cp -f /vagrant/provision/config/nginx-host.conf /etc/nginx/conf.d/nginx-host.conf
 
message 'INSTALL PHP'

sudo apt-get -y install \
    php7.2-fpm \
    php7.2-mysql \
    php7.2-curl \
    php7.2-intl \
    php7.2-gd \
    php7.2-sqlite3 \
    php7.2-cli \
    php7.2-zip \
    php7.2-soap \
    php7.2-bcmath \
    php7.2-ctype \
    php7.2-fileinfo \
    php7.2-json \
    php7.2-mbstring \
    php7.2-pdo \
    php7.2-tokenizer \
    php7.2-xml


sudo cp -f /vagrant/provision/config/php.ini /etc/php/7.2/fpm/php.ini

message 'INSTALL MARIADB'

sudo apt-get -y install mysql-server

message 'ALLOW ACCESS TO MARIADB REMOTELY (FOR GUI CLIENTS)'

sudo sh -c "echo '\n' >> /etc/mysql/my.cnf"
sudo sh -c "echo '[mysqld]' >> /etc/mysql/my.cnf"
sudo sh -c "echo 'skip-networking=0' >> /etc/mysql/my.cnf"
sudo sh -c "echo 'skip-bind-address' >> /etc/mysql/my.cnf"
sudo sh -c "echo 'innodb_log_file_size = 128M' >> /etc/mysql/my.cnf"

sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.%' IDENTIFIED BY '12345' WITH GRANT OPTION;"

message 'SET MARIADB ROOT PASSWORD'

sudo mysql -u root -e "UPDATE mysql.user SET Password = PASSWORD('12345'), Plugin = '' WHERE User = 'root';"

message 'RESTART SERVICES'

sudo service nginx restart
sudo service php7.2-fpm restart
sudo service mysql restart

message 'INSTALL COMPOSER'

cd /vagrant/www

EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
fi

php composer-setup.php --quiet
rm composer-setup.php

sudo mv composer.phar /usr/local/bin/composer

message 'DONE! MACHINE IP ADDRESS IS:'

hostname -I | awk '{print $2}'



