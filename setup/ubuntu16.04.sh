#!/bin/bash

# Basic Setup Installer for Ubuntu 16.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/server-installers


# IPv4/IPv6 Configuration
disableIpv6=false
echo "IPv4/IPv6: Do you want to disabled IPv6? [Y/n, empty as No]:"
read yn
case $yn in
    [Yy]* ) disableIpv6=true;;
    * ) 
esac

# Access Configuration
sshPasswodAuthOn=false
echo "SSH Login: Do you want turn on SSH PasswordAuthentication? [Y/n, empty as No]:"
read yn
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
if [ $disableIpv6 ]; then
    if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
        sudo printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
        sysctl -p
        echo "IPv6 Disabled"
    fi
fi