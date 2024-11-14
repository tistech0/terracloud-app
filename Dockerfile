# Utilisez une image Docker officielle pour PHP 7.4 avec Apache
FROM php:7.4-apache

# Définir les arguments de build
ARG DB_CONNECTION
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD

# Installez les extensions PHP nécessaires
RUN docker-php-ext-install pdo_mysql

RUN apt-get update && apt-get install -y git unzip p7zip-full

# Installez Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiez le script d'entrypoint et rendez-le exécutable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copiez les fichiers de l'application dans le conteneur
COPY . /var/www/html/

# Créer les répertoires nécessaires
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/app/public \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/testing \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/storage/logs

# Définir les permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Créer et configurer le fichier .env
COPY .env.example /var/www/html/.env
RUN sed -i "s#DB_CONNECTION=.*#DB_CONNECTION=${DB_CONNECTION}#" /var/www/html/.env && \
    sed -i "s#DB_HOST=.*#DB_HOST=${DB_HOST}#" /var/www/html/.env && \
    sed -i "s#DB_PORT=.*#DB_PORT=${DB_PORT}#" /var/www/html/.env && \
    sed -i "s#DB_DATABASE=.*#DB_DATABASE=${DB_DATABASE}#" /var/www/html/.env && \
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#" /var/www/html/.env && \
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#" /var/www/html/.env

# Installez les dépendances de l'application
WORKDIR /var/www/html
RUN composer install --no-dev --no-interaction --prefer-dist

# Modifiez la configuration d'Apache pour pointer vers le répertoire public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Activez le module Apache Rewrite
RUN a2enmod rewrite

# Exposez le port 80
EXPOSE 80

# Définir l'entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]