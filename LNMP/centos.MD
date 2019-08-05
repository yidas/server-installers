CENTOS Note
===========

PHP 7
-----

Install yum-utils & enable epel repository

```
$ yum install epel-release yum-utils -y
```

Download and Install remirepo

```
$ yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
```

Configure the PHP 7.x repository (Choose one)

```
# PHP 7.0
$ yum-config-manager --enable remi-php70
# PHP 7.1
$ yum-config-manager --enable remi-php71
# PHP 7.2
$ yum-config-manager --enable remi-php72
# PHP 7.3
$ yum-config-manager --enable remi-php73
```

Install PHP:

```
$ yum install php php-common php-opcache php-cli php-gd php-curl php-mysql -y
```
