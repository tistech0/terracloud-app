FROM php:8.1-apache

# Extensions et dépendances
RUN docker-php-ext-install pdo_mysql
RUN apt-get update && apt-get install -y git unzip p7zip-full

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Structure correcte de l'application
COPY . /var/www/html/
WORKDIR /var/www/html

# Apache et permissions
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN a2enmod rewrite

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Installation des dépendances
RUN composer install --no-dev --no-interaction --prefer-dist

EXPOSE 80
CMD ["apache2-foreground"]