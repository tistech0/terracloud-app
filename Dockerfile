# Utilisez une image Docker officielle pour PHP 8.1 avec Apache
FROM php:8.1-apache

ENV DOCKERIZE_VERSION v0.9.1

# Installez les extensions PHP nécessaires
RUN docker-php-ext-install pdo_mysql

# Installez des outils nécessaires
RUN apt-get update && apt-get install -y git unzip p7zip-full curl wget

# Installez Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installez Dockerize (v0.9.1)
RUN wget -O dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz \
    && rm dockerize.tar.gz \
    && chmod +x /usr/local/bin/dockerize \
    && apt-get autoremove -yqq --purge wget \
    && rm -rf /var/lib/apt/lists/*

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
CMD ["dockerize", "-template", "/var/www/html/.env.tmpl:/var/www/html/.env", "apache2-foreground"]
