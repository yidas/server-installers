#!/bin/bash

# Python Nginx+uWSGI Installer for Ubuntu 16.04 TLS
#
# @author  Nick Tsai <myintaer@gmail.com>
# @version 1.0.0
# @link    https://github.com/yidas/server-installers

# APT Source using IPv4
sudo apt-get update

# Nginx
sudo apt-get install nginx -y

# Python 3 with uWSGI
sudo apt-get install python3 python3-pip -y
python3 -m pip install --upgrade pip
python3 -m pip install uwsgi

# Python project
projectPath="/var/www/python-project/"
mkdir "${projectPath}"
configUrl='https://raw.githubusercontent.com/yidas/server-installers/master/python-web-server/py/response.py'
sudo wget "${configUrl}" -O "${projectPath}/response.py"

# Nginx Default Site
configUrl='https://raw.githubusercontent.com/yidas/server-installers/master/python-web-server/nginx-sites/deafult-uwsgi'
sudo wget "${configUrl}" -O /etc/nginx/sites-available/default

# Run uWSGI in the backgroud
uwsgi --socket :8001 --wsgi-file /var/www/python-project/response.py &

sudo service nginx reload
