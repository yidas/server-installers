#!/bin/bash

# LNMP Installer for Ubuntu 18.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/server-installers

for cmd in wget apt apt-get sudo service tar mv rm
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
# PHP 7.0
usePhp70=false;
echo "PHP: Do you want to additionally install PHP 7.0? [Y/n, empty as No]"
read yn
case $yn in
    [Yy]* ) usePhp70=true;;
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

# APT Source using IPv4
sudo apt-get update

# Apache
sudo apt-get install apache2 -y

# PHP
sudo apt-get install php-fpm php-mysql php-cli php-curl php-mbstring php-imagick php-gd php-xml php-zip -y
sudo apt-get install php-memcached memcached -y
# Apache PHP Mod
sudo apt-get install libapache2-mod-php -y

if [ $usePhp73 = true ] || [ $usePhp70 = true ] || [ $usePhp5 = true ]; then
    # PPA
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt-get update
fi

if [ $usePhp73 = true ]; then
    # PHP 7.3
    sudo apt-get install php7.3-fpm php7.3-mysql php7.3-cli php7.3-curl php7.3-mbstring php7.3-imagick php7.3-gd php7.3-xml php7.3-zip -y
    # Apache PHP Mod (To swicth mod: `a2dismod php7.2` > `a2enmod php7.3` then restart Apache)
    sudo apt-get install libapache2-mod-php7.3 -y
fi

if [ $usePhp70 = true ]; then
    # PHP 7.0
    sudo apt-get install php7.0-fpm php7.0-mysql php7.0-cli php7.0-mcrypt php7.0-curl php7.0-mbstring php7.0-imagick php7.0-gd php7.0-xml php7.0-zip -y
    # Apache PHP Mod (To swicth mod: `a2dismod php7.2` > `a2enmod php7.0` then restart Apache)
    sudo apt-get install libapache2-mod-php7.0 -y
fi

if [ $usePhp5 = true ]; then
    # PHP 5.6
    sudo apt-get install php5.6-fpm php5.6-mysql php5.6-cli php5.6-mcrypt php5.6-curl php5.6-mbstring php5.6-imagick php5.6-gd php5.6-xml php5.6-zip -y
    # Apache PHP Mod (To swicth mod: `a2dismod php7.2` > `a2enmod php5.6` then restart Apache)
    sudo apt-get install libapache2-mod-php5.6 -y
fi

# MySQL
if [ $installMySQL = true ]; then
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${mysqlRootPassword}"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${mysqlRootPassword}"
    sudo apt-get install mysql-server -y
fi

# PHPMyAdmin
if [ $installPhpMyAdmin = true ]; then
    # Configuration
    version="4.8.2"
    webPath="/var/www/html/"
    #filename="phpMyAdmin-${version}-english"
    filename="phpMyAdmin-${version}-all-languages"
    fileUrl="https://files.phpmyadmin.net/phpMyAdmin/${version}/${filename}.tar.gz"
    # Commands
    sudo wget "${fileUrl}"
    sudo tar -zxvf "${filename}.tar.gz" -C "${webPath}"
    sudo rm -f "${filename}.tar.gz"
    sudo mv "${webPath}${filename}" "${webPath}phpmyadmin"
    # Nginx Default Site
    configUrl='https://raw.githubusercontent.com/yidas/server-installers/master/LNMP/nginx-sites/default-php7.2-all'
    
    sudo wget "${configUrl}" -O /etc/nginx/sites-available/default
    
    # PHPMyAdmin theme
    if [ $installPhpMyAdminTheme = true ]; then
        # Configuration
        file="metro-2.8.zip"
        fileUrl="https://files.phpmyadmin.net/themes/metro/2.8/${file}"
        # Commnads
        pathTheme="${webPath}phpmyadmin/themes"
        sudo wget "${fileUrl}" -P "${pathTheme}"
        sudo apt install unzip -y
        sudo unzip "${pathTheme}/${file}" -d "${pathTheme}/"
        sudo rm "${pathTheme}/${file}"
    fi
fi

sudo service apache2 reload
