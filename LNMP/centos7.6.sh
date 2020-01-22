#!/bin/bash

# LNMP Installer for CentOS 7.6 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/server-installers

# Pre-installation
sudo yum install wget -y

# Program commands check
for cmd in yum sudo tar mv rm
do
    if ! hash $cmd 2>/dev/null
    then
        echo "The required program '$cmd' is currently not installed. To run '$cmd' please ask your administrator to install the package '$cmd'"
        exit 1
    fi
done

# PHP
phpVersion=70;
echo "PHP: Enter the version you want to install. [Default is 7.0]
56 => 5.6
70 => 7.0
71 => 7.1
72 => 7.2
73 => 7.3"

read input
if [ -n "$input" ]; then
    phpVersion=$input;
fi

# MySQL question
echo "MySQL: Do you want to install MySQL? [Y/n, empty as Yes]"
read yn
case $yn in
    [Nn]* ) installMySQL=false;;
    * ) 
        installMySQL=true
        
        echo "MySQL: Type the password for MySQL root, default is \`password\` followed by [ENTER]:"
        read -s mysqlRootPassword
        if [ ! $mysqlRootPassword ]; then
            mysqlRootPassword='password'
        fi
esac

# PHPMyAdmin question
echo "PHPMyAdmin: Do you want to install PHPMyAdmin? [Y/n, empty as Yes]"
read yn
case $yn in
    [Nn]* ) installPhpMyAdmin=false;;
    * ) installPhpMyAdmin=true;;
esac
# PHPMyAdmin with Metro theme
if [ $installPhpMyAdmin = true ]; then
    echo "PHPMyAdmin: Do you want to install Metro theme? [Y/n, empty as Yes]"
    read yn
    case $yn in
        [Nn]* ) installPhpMyAdminTheme=false;;
        * ) installPhpMyAdminTheme=true;;
    esac
fi

# Update package repositories
sudo yum update -y

# Nginx
sudo yum install epel-release -y
sudo yum install nginx -y
sudo systemctl start nginx

# PHP
sudo yum install epel-release yum-utils -y
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
sudo yum-config-manager --enable remi-php"${phpVersion}"
sudo yum install php php-fpm php-cli php-common php-opcache php-gd php-curl php-mysql -y
# PHP-FPM Nginx user
sudo sed -i '/user = apache/c\user = nginx' /etc/php-fpm.d/www.conf
sudo sed -i '/group = apache/c\group = nginx' /etc/php-fpm.d/www.conf
# PHP-FPM Session permission
sudo chown -R nginx:nginx /var/lib/php/session
# CentOS Default Site
sudo sed -i '/listen       80/c\#listen       80' /etc/nginx/nginx.conf
sudo sed -i '/listen       \[::\]:80/c\#listen       \[::\]:80' /etc/nginx/nginx.conf
configUrl='https://raw.githubusercontent.com/yidas/server-installers/master/LNMP/nginx-sites/centos-tcp-php.conf'
sudo wget "${configUrl}" -O /etc/nginx/conf.d/default.conf

# MySQL
if [ $installMySQL = true ]; then
    wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
    sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
    sudo yum update -y
    sudo yum install mysql-server -y
    sudo systemctl start mysqld
    mysql -uroot -Bse "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${mysqlRootPassword}');"
fi

# PHPMyAdmin
if [ $installPhpMyAdmin = true ]; then
    # Configuration
    version="4.8.2"
    webPath="/usr/share/nginx/html/"
    #filename="phpMyAdmin-${version}-english"
    filename="phpMyAdmin-${version}-all-languages"
    fileUrl="https://files.phpmyadmin.net/phpMyAdmin/${version}/${filename}.tar.gz"
    # Commands
    sudo wget "${fileUrl}"
    sudo tar -zxvf "${filename}.tar.gz" -C "${webPath}"
    sudo rm -f "${filename}.tar.gz"
    sudo mv "${webPath}${filename}" "${webPath}phpmyadmin"
    # Nginx Default Site
    configUrl='https://raw.githubusercontent.com/yidas/server-installers/master/LNMP/nginx-sites/centos-tcp-php.conf'
    
    sudo wget "${configUrl}" -O /etc/nginx/sites-available/default
    
    # PHPMyAdmin theme
    if [ $installPhpMyAdminTheme = true ]; then
        # Configuration
        file="metro-2.8.zip"
        fileUrl="https://files.phpmyadmin.net/themes/metro/2.8/${file}"
        # Commnads
        pathTheme="${webPath}phpmyadmin/themes"
        sudo wget "${fileUrl}" -P "${pathTheme}"
        sudo yum install unzip -y
        sudo unzip "${pathTheme}/${file}" -d "${pathTheme}/"
        sudo rm "${pathTheme}/${file}"
    fi
fi

sudo systemctl restart php-fpm
sudo systemctl restart nginx
exit
