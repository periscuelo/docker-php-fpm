# NGINX + PHP FPM + composer + PHPUnit + MySQL

#### A simple docker-compose configuration to use NGINX, PHP FPM and MySQL for development

Below follow one example with laravel in port 80 and PHP in 443.  
If you don't want use laravel in port 80, just remove `/mylaravelproject/public` from `default.conf` file.

## Requiriments
Have a local folder named htdocs and other named mysql

`$ mkdir htdocs`  
`$ mkdir mysql`

For a test, make a file named index.php and save in htdocs folder created before.
#### content of index.php
```php
<?php phpinfo(); ?>
```

And you can *create and edit* too the php.ini, default.conf and my.cnf as you need.  
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
```

### my.cnf
#### If you are using docker toolbox on windows, this file needs to be read-only.

```
[mysqld]
innodb_use_native_aio=0
[mysql]
user=root
password=root
```

### docker-compose

#### The `php.ini` volume is necessary only if you want change something there.

```
# docker-compose.yml
version: '3'

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
    depends_on:
      - db
  db:
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - ./my.cnf:/etc/mysql/conf.d/my.cnf
      - ../mysql:/var/lib/mysql
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
