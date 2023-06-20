#!/bin/bash

# LNMP Installer for Ubuntu 20.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/server-installers

# Interactive process ---

for cmd in wget apt apt-get service tar mv rm
do
    if ! hash $cmd 2>/dev/null
    then
        echo "The required program '$cmd' is currently not installed. To run '$cmd' please ask your administrator to install the package '$cmd'"
        exit 1
    fi
done

# PHP 7.3
usePhp73=false;
echo "PHP: Do you want to additionally install PHP 7.3? [Y/n, empty as No]"
read yn
case $yn in
    [Yy]* ) usePhp73=true;;
    * ) 
esac
# PHP 5.6
usePhp5=false;
echo "PHP: Do you want to additionally install PHP 5.6? [Y/n, empty as No]"
read yn
case $yn in
    [Yy]* ) usePhp5=true;;
    * ) 
esac

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
        ;;
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

# Installation process ---

# APT Source using IPv4
apt-get update

# Tzdata
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata

# Nginx
apt-get install nginx -y

# PHP
apt-get install php-fpm php-mysql php-cli php-curl php-mbstring php-imagick php-gd php-xml php-zip -y
apt-get install php-memcached memcached -y

if [ $usePhp73 = true ] || [ $usePhp5 = true ]; then
    # PPA
    apt-get install software-properties-common -y
    add-apt-repository ppa:ondrej/php -y
    apt-get update
fi

if [ $usePhp73 = true ]; then
    # PHP 7.3
    apt-get install php7.3-fpm php7.3-mysql php7.3-cli php7.3-curl php7.3-mbstring php7.3-imagick php7.3-gd php7.3-xml php7.3-zip -y
fi

if [ $usePhp5 = true ]; then
    # PHP 5.6
    apt-get install php5.6-fpm php5.6-mysql php5.6-cli php5.6-mcrypt php5.6-curl php5.6-mbstring php5.6-imagick php5.6-gd php5.6-xml php5.6-zip -y
fi

# MySQL
if [ $installMySQL = true ]; then
    debconf-set-selections <<< "mysql-server mysql-server/root_password password ${mysqlRootPassword}"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${mysqlRootPassword}"
    apt-get install mysql-server -y
fi

# PHPMyAdmin
if [ $installPhpMyAdmin = true ]; then
    # Configuration
    version="5.2.1"
    webPath="/var/www/html/"
    #filename="phpMyAdmin-${version}-english"
    filename="phpMyAdmin-${version}-all-languages"
    fileUrl="https://files.phpmyadmin.net/phpMyAdmin/${version}/${filename}.tar.gz"
    # Commands
    wget "${fileUrl}"
    tar -zxvf "${filename}.tar.gz" -C "${webPath}"
    rm -f "${filename}.tar.gz"
    mv "${webPath}${filename}" "${webPath}phpmyadmin"
    # Nginx Default Site
    configUrl='https://raw.githubusercontent.com/yidas/server-installers/master/LNMP/nginx-sites/default-php7.4-all'
    
    wget "${configUrl}" -O /etc/nginx/sites-available/default
    
    # PHPMyAdmin theme
    if [ $installPhpMyAdminTheme = true ]; then
        # Configuration
        file="metro-2.8.1.zip"
        fileUrl="https://files.phpmyadmin.net/themes/metro/2.8.1/${file}"
        # Commnads
        pathTheme="${webPath}phpmyadmin/themes"
        wget "${fileUrl}" -P "${pathTheme}"
        apt install unzip -y
        unzip -o "${pathTheme}/${file}" -d "${pathTheme}/"
        rm "${pathTheme}/${file}"
    fi
fi

service nginx reload
service nginx start
service php7.4-fpm start

