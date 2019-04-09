#!/bin/bash

# Postfix SMTP with Dovecot SASL for Ubuntu 16.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/shell

# IPv6 Disabled
if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
    sudo printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p
    echo "IPv6 Disabled"
fi

# APT Source using IPv4
sudo apt-get update

# Packages
sudo apt install postfix -y
sudo apt install dovecot.core -y

# Postfix setting for Dovecot SASL
sudo postconf -e 'smtpd_sasl_type = dovecot'
sudo postconf -e 'smtpd_sasl_path = private/auth'
sudo postconf -e 'smtpd_sasl_local_domain ='
sudo postconf -e 'smtpd_sasl_security_options = noanonymous'
sudo postconf -e 'broken_sasl_auth_clients = yes'
sudo postconf -e 'smtpd_sasl_auth_enable = yes'
sudo postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'

# Dovecot SASL setting for Postfix
if ! grep -q " unix_listener /var/spool/postfix/private/auth" /etc/dovecot/conf.d/10-master.conf; then
    sed -i '/# Postfix smtp-auth/c\  # Postfix smtp-auth\n  unix_listener /var/spool/postfix/private/auth {\n    mode=0600\n  }' /etc/dovecot/conf.d/10-master.conf
fi
sed -i '/auth_mechanisms = plain/c\auth_mechanisms = plain login' /etc/dovecot/conf.d/10-auth.conf

sudo service dovecot reload
sudo service postfix reload
