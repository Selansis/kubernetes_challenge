FROM php:7.4-apache
# installing mysqli extension
RUN docker-php-ext-install mysqli
# copying app source code to new folder
COPY /home/wojtek/app/ /var/www/html/
# exposing port 80 to allow traffic 
EXPOSE 80