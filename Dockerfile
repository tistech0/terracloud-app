# Utilisez une image Docker officielle pour PHP 7.4 avec Apache
FROM php:8.1-apache

# Installez les extensions PHP nécessaires
RUN docker-php-ext-install pdo_mysql

# Installez des outils nécessaires
RUN apt-get update && apt-get install -y git unzip p7zip-full curl

# Installez Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installez Dockerize
RUN curl -sSL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64 -o /usr/local/bin/dockerize && \
    chmod +x /usr/local/bin/dockerize

# Copiez les fichiers de l'application dans le conteneur
COPY . /var/www/html/

# Installez les dépendances de l'application
RUN composer install

# Définir les permissions pour Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Modifier la configuration d'Apache pour pointer vers le répertoire public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Activez le module Apache Rewrite
RUN a2enmod rewrite

# Exposez le port 80
EXPOSE 80

# Commande par défaut pour valoriser le fichier .env et démarrer Apache
CMD dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env apache2-foreground
