#!/bin/bash

# LNMP Installer for Ubuntu 16.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/shell

# Access Configuration
sshPasswodAuthOn=false
echo "SSH Login: Do you want turn on SSH PasswordAuthentication? [Y/n, empty as No]:"
read sshPasswodAuthOn
case $yn in
    [Yy]* ) sshPasswodAuthOn=true;;
    * ) 
esac

echo "Sudoer User: Type the sudoer user name if you want to create, empty to skip, followed by [ENTER]:"
read sudoerUsername

sudoerPassword=''
if [ $sudoerUsername ]; then
    echo "Sudoer User: Type the password for sudoer user \`{$sudoerUsername}\` if you want to create, or empty, followed by [ENTER]:"
    read sudoerPassword
fi

# PHP
usePhp5=false;
# PHP default
echo "PHP: Do you want to additionally install PHP 5.6? [Y/n, empty as No]"
read yn
case $yn in
    [Yy]* ) usePhp5=true;;
    * ) 
esac
# PHP force asking
#while true; do
#    echo "PHP: Default version is PHP 7, install old version PHP 5.6? [Y/n]"
#    read yn
#    case $yn in
#        [Yy]* ) usePhp5=true; break;;
#        [Nn]* ) break;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done

# MySQL question
echo "MySQL: Do you want to install MySQL? [Y/n, empty as Yes]"
read yn
case $yn in
    [Nn]* ) installMySQL=false;;
    * ) 
        installMySQL=true
        
        echo "MySQL: Type the password for MySQL root, default is \`password\` followed by [ENTER]:"
        read mysqlRootPassword
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

# Access
if [ $sshPasswodAuthOn ]; then
    # Root Login Disabled
    sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sudo service ssh reload
fi

# Sudoer
if [ $sudoerUsername ]; then
    sudo adduser ${sudoerUsername} --gecos "" --disabled-password
    echo "${sudoerUsername}:${sudoerPassword}" | sudo chpasswd
    sudo usermod -a -G sudo ${sudoerUsername}
else
    echo "Skip creating user"
fi

# IPv6 Disabled
if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
    sudo printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p
    echo "IPv6 Disabled"
fi

# APT Source using IPv4
sudo apt-get update

# Timezone
sudo timedatectl set-timezone Asia/Taipei
sudo apt-get install ntpdate -y
sudo ntpdate time.stdtime.gov.tw

# Nginx
sudo apt-get install nginx -y


# PHP
sudo apt-get install php-fpm php-mysql php-cli php-mcrypt php-curl php-mbstring php-imagick php-gd php-xml php-zip -y
sudo apt-get install php-memcached memcached -y
sudo phpenmod mcrypt

if [ $usePhp5 = true ]; then
    # PHP 5.6
    sudo apt-get install software-properties-common -y
    sudo apt-get install python-software-properties -y
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt-get update
    sudo apt-get install php5.6-fpm php5.6-mysql php5.6-cli php5.6-mcrypt php5.6-curl php5.6-mbstring php5.6-imagick php5.6-gd php5.6-xml php5.6-zip -y
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
    if [ $usePhp5 = true ]; then
        # configUrl='https://raw.githubusercontent.com/yidas/shell/master/installer/config/nginx/sites-enabled/default-php5.6'
        configUrl='https://raw.githubusercontent.com/yidas/shell/master/installer/config/nginx/sites-enabled/default-php7.0'
    else
        configUrl='https://raw.githubusercontent.com/yidas/shell/master/installer/config/nginx/sites-enabled/default-php7.0'
    fi
    
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

sudo service nginx reload
