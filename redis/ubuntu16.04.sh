#!/bin/bash

# Redis Installer for Ubuntu 16.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/shell


# PHP
installAdmin=false;
# PHP default
echo "PHP: Do you want to install phpRedisAdmin? [Y/n, empty as No]"
read yn
case $yn in
    [Yy]* ) installAdmin=true;;
    * ) 
esac

# IPv6 Disabled
if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
    sudo printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p
    echo "IPv6 Disabled"
fi

# APT Source using IPv4
sudo apt update

# Timezone
sudo timedatectl set-timezone Asia/Taipei
sudo apt install ntpdate -y
sudo ntpdate time.stdtime.gov.tw

# Redis
sudo apt install redis-server -y

# phpRedisAdmin
if [ $installAdmin = true ]; then

  # Nginx
  sudo apt install nginx -y

  # PHP
  sudo apt-get install php-fpm php-mysql php-cli php-mcrypt php-curl php-mbstring php-imagick php-gd php-xml php-zip -y
  sudo apt-get install php-memcached memcached -y
  sudo phpenmod mcrypt
  
  # Install admin
  # Composer
  curl -s http://getcomposer.org/installer | php
  php composer.phar create-project erik-dubbelboer/php-redis-admin /var/www/html/redis
  # Site setting
  configUrl='https://raw.githubusercontent.com/yidas/shell/master/installer/config/nginx/sites-enabled/default-php7.0'
  sudo wget "${configUrl}" -O /etc/nginx/sites-available/default
  sudo service nginx reload
fi

