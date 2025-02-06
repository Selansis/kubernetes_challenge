FROM php:7.4-apache

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

WORKDIR /var/www/html/

COPY /app .

ENV DB_HOST=mysql-service \
    DB_USER=ecomuser \
    DB_PASSWORD=ecompassword \
    DB_NAME=ecomdb

EXPOSE 80

CMD ["apache2-foreground"]