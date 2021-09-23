# NGINX + PHP FPM + composer + PHPUnit + MySQL

#### A simple docker-compose configuration to use NGINX, PHP FPM and MySQL for development

Below follow one example with laravel in port 80 and PHP in 443.  
If you don't want use laravel in port 80, just remove `/mylaravelproject/public` from `default.conf` file.

## Requiriments
Have a local folder named htdocs, one named mysql and other named mysql-dump

`$ mkdir htdocs`  
`$ mkdir mysql`  
`$ mkdir mysql-dump`

For a test, make a file named index.php and save in htdocs folder created before.
#### content of index.php
```php
<?php phpinfo(); ?>
```

And inside of mysql-dump put one file named grant_privileges.sql with below:
#### content of grant_privileges.sql
```
GRANT ALL PRIVILEGES ON my_db.* TO 'myuser'@'%';
```

And you can *create and edit* too the php.ini, php-fpm.ini, default.conf, xdebug.ini and my.cnf as you need.

You can skip the xdebug service if you wanna. But is a good workaround to avoid be slow, using this in another container.

If you don't need of xdebug you can change below in default.conf of nginx:

```
fastcgi_pass php:9000;
if ($arg_xdebug) {
    fastcgi_pass php_xdebug:9000;
}
```

to

`fastcgi_pass php:9000;`

Now you are ready for the next step.

## Usage

### NGINX default.conf

```
server {
    listen 80;
    index index.php index.html;
    server_name localhost;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html/mylaravelproject/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;

    large_client_header_buffers 4 10M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;

        fastcgi_pass php:9000;
        if ($arg_xdebug) {
            fastcgi_pass php_xdebug:9000;
        }

        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

server {
    listen 443 ssl;
    index index.php index.html;
    server_name localhost;
    ssl_certificate /etc/ssl/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/ssl-cert-snakeoil.key;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html;

    charset utf-8;

    large_client_header_buffers 4 10M;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;

        fastcgi_pass php:9000;
        if ($arg_xdebug) {
            fastcgi_pass php_xdebug:9000;
        }

        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

### php.ini

```
max_execution_time = 32000
post_max_size = 60M
upload_max_filesize = 60M
date.timezone = America/Sao_Paulo
max_input_vars = 20000
memory_limit = 512M
zend_extension=opcache.so
opcache.enable = 1
opcache.memory_consumption = 128
opcache.max_accelerated_files = 10000
opcache.revalidate_freq = 60
opcache.use_cwd = 1
opcache.validate_timestamps = 1
opcache.save_comments = 1
opcache.enable_file_override = 0
opcache.fast_shutdown = 1
opcache.enable_cli = 1

# xdebug php-fpm 7.0 or 7.1: use below on xdebug.ini
; xdebug.remote_enable = 1
; xdebug.remote_autostart = 1
; xdebug.remote_host = host.docker.internal
; xdebug.remote_port = 9003
; xdebug.remote_connect_back = 1
; xdebug.idekey = VSCODE
; xdebug.remote_log = /tmp/xdebug.log

# xdebug php-fpm 7.3 or newer: use below on xdebug.ini
; xdebug.mode = debug
; xdebug.start_with_request = yes
; xdebug.client_host = host.docker.internal
; xdebug.discover_client_host = 1
; xdebug.idekey = VSCODE
; xdebug.log = /tmp/xdebug.log
```

### php-fpm.ini

```
security.limit_extensions = .php
pm = ondemand
pm.max_children = 12
pm.min_spare_servers = 2
pm.max_spare_servers = 4
pm.start_servers = 12
pm.max_requests = 500
pm.process_idle_timeout = 10s
```

### my.cnf
#### If you are using docker toolbox on windows, this file needs to be read-only.

```
[mysqld]
innodb_use_native_aio=0
max_allowed_packet=1024M
innodb_buffer_pool_size=2048M
innodb_log_buffer_size=512M
```

### docker-compose

#### The `php.ini` and `php-fpm.ini` volume is necessary only if you want change something there.

>If you don't need of xdebug you can avoid the php_xdebug service

```
# docker-compose.yml
version: '3.8'

services:
  webserver:
    image: periscuelo/nginx-ssl
    restart: always
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./htdocs:/var/www/html
      - ./default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
  php:
    image: periscuelo/php-fpm:7.3
    restart: always
    ports:
      - 9000:9000
    volumes:
      - ./htdocs:/var/www/html
      - ./php.ini:/usr/local/etc/php/php.ini
      - ./php-fpm.ini:/etc/php7/fpm/pool.d/www.conf
    depends_on:
      db:
        condition: service_healthy
  php_xdebug:
    image: periscuelo/php-fpm:7.3-XDebug
    ports:
      - 9001:9000
    volumes:
      - ./htdocs:/var/www/html
      - ./xdebug.ini:/usr/local/etc/php/php.ini
  db:
    image: mysql
    cap_add:
      - SYS_NICE
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=toor
      - MYSQL_DATABASE=my_db
      - MYSQL_USER=myuser
      - MYSQL_PASSWORD=myuser
    volumes:
      - ./my.cnf:/etc/mysql/conf.d/my.cnf
      - ./mysql:/var/lib/mysql
      - ./mysql-dump:/docker-entrypoint-initdb.d
    healthcheck:
      test: mysqladmin ping -h 127.0.0.1 -u $$MYSQL_USER --password=$$MYSQL_PASSWORD
      timeout: 10s
      retries: 10
```
`$ docker-compose up -d`

### PHP Composer
You can use the `composer` too. For this, use the following command:

`$ docker exec -it ID_OR_NAME_OF_YOUR_CONTAINER bash`

You have to replace `ID_OR_NAME_OF_YOUR_CONTAINER` for  the respective Container ID or Container NAME.  
Ex: If my container id is f3c99c3239ex then, the command must be:

`$ docker exec -it f3c99c3239ex bash`

Inside the terminal you can use the `composer` as you want.  
For example:

`$ composer create-project phpmyadmin/phpmyadmin`

You can use phpmyadmin to made changes in your MySQL Database.  
For exit of terminal after, the command must be:

`$ exit`

And you come out of container.

# Enjoy

You can access the server by https://localhost or http://localhost now!  
Put your PHP files in htdocs to access by URL. Have fun =)
