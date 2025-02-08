FROM php:7.4-apache
#installing db extensions for php
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql
#copying source code
COPY ./app /var/www/html/
#exposing port 80
EXPOSE 80