*Python Web Server*
===================

Python Web Environment Building

INSTALLATION
------------

Select your Linux distribution to download and execute the installer as below:

> You can make installer executable by `$ chmod +x ./installer` then `$ ./installer`.

### Python Web

#### Ubuntu 16.04 LTS

> Nginx: 1.10.3  
> Python: 3.5.2
> Python pip: 19.0.3 (Newest upgrade from 8.1.1)  
> Python uWSGI: 2.0.18 (From pip) 
>
> *Python project is placed at `/var/www/python-project/` and uWSGI will run in background so that you can access via `http://yourhost/`.*

```
$ wget https://raw.githubusercontent.com/yidas/server-installers/master/python-web-server/nginx-uwsgi_ubuntu16.04.sh -O installer
$ bash installer
```

#### Ubuntu 18.04 LTS

> Nginx: 1.14.0  
> Python: 3.6.7
> Python pip: 19.0.3 (Newest upgrade from 9.0.1)  
> Python uWSGI: 2.0.18 (From pip) 
>
> *Python project is placed at `/var/www/python-project/` and uWSGI will run in background so that you can access via `http://yourhost/`.*

```
$ wget https://raw.githubusercontent.com/yidas/server-installers/master/python-web-server/nginx-uwsgi_ubuntu18.04.sh -O installer
$ bash installer
```

### Django

#### Ubuntu 16.04 LTS

> Nginx: 1.10.3  
> Python: 3.5.2
> Python pip: 19.0.3 (Newest upgrade from 8.1.1)  
> Python uWSGI: 2.0.18 (From pip)  
> Python Django: 2.2 (From pip)
>
> *Django project is placed at `/var/www/mysite/` and uWSGI will run in background so that you can access via `http://yourhost/admin`.*

```
$ wget https://raw.githubusercontent.com/yidas/server-installers/master/django-python-web-server/nginx-uwsgi_ubuntu16.04.sh -O installer
$ bash installer
```

#### Ubuntu 18.04 LTS

> Nginx: 1.14.0  
> Python: 3.6.7
> Python pip: 19.0.3 (Newest upgrade from 8.1.1)  
> Python uWSGI: 2.0.18 (From pip)  
> Python Django: 2.2 (From pip)
>
> *Django project is placed at `/var/www/mysite/` and uWSGI will run in background so that you can access via `http://yourhost/admin`.*

```
$ wget https://raw.githubusercontent.com/yidas/server-installers/master/django-python-web-server/nginx-uwsgi_ubuntu18.04.sh -O installer
$ bash installer
```

