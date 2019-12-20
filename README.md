# PHP FPM + composer + PHPUnit

#### A simple docker configuration to use PHP FPM for development

This is a simple Dockerfile that uses the latest PHP-FPM image. This is suitable for development and testing, not for production.

## Requiriments
Have a local folder named htdocs

`$ mkdir htdocs`

For a test, make a file named index.php and save in htdocs folder created before.
#### content of index.php
```php
<?php phpinfo(); ?>
```

And you can *create and edit* too the php.ini as you need.  
Now you are ready for the next step.

## Usage

### MAC or Linux
`$ docker container run -d -p 9000:9000 -v $(pwd)/htdocs:/var/www/ periscuelo/php-fpm`
#### with php.ini
`$ docker container run -d -p 9000:9000 -v $(pwd)/htdocs:/var/www/ -v $(pwd)/php.ini:/usr/local/etc/php/php.ini periscuelo/php-fpm`

### Windows PowerShell
`$ docker container run -d -p 9000:9000 -v ${pwd}/htdocs:/var/www/ periscuelo/php-fpm`
#### with php.ini
`$ docker container run -d -p 9000:9000 -v ${pwd}/htdocs:/var/www/ -v ${pwd}/php.ini:/usr/local/etc/php/php.ini periscuelo/php-fpm`


### docker-compose

#### The `php.ini` volume is necessary only if you want change something there.

```
# docker-compose.yml
version: '3'

services:
  php:
    image: periscuelo/php-fpm
    ports:
      - 9000:9000
    volumes:
      - ./htdocs:/var/www
      - ./php.ini:/usr/local/etc/php/php.ini
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

Put your PHP files in htdocs to access by command. Have fun =)
