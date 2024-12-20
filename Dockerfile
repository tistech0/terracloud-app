# Utilisez une image Docker officielle pour PHP 8.1 avec Apache
FROM php:8.1-apache

# Définir les variables d'environnement
ENV DOCKERIZE_VERSION v0.9.1
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Définir le contexte de travail
WORKDIR /var/www/html

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install pdo_mysql

# Installer les outils nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip p7zip-full curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installer Dockerize
RUN wget -O dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz \
    && rm dockerize.tar.gz \
    && chmod +x /usr/local/bin/dockerize

# Copier les fichiers de l'application
COPY . /var/www/html/

# Vérifier la présence des fichiers
RUN echo "Vérification des fichiers copiés" && ls -la /var/www/html/ && ls -la /var/www/html/public

# Installer les dépendances Laravel
RUN composer install --optimize-autoloader --no-dev

# Définir les permissions pour Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Modifier la configuration d'Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Ajouter une configuration explicite pour Apache
RUN echo '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/custom-public.conf && \
    a2enconf custom-public

# Activer le module Apache Rewrite
RUN a2enmod rewrite

# Exposer le port 80
EXPOSE 80

# Commande par défaut
CMD ["sh", "-c", "echo 'Vérification des fichiers copiés :'; ls -la /var/www/html/.env.tmpl /var/www/html/public && dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env apache2-foreground"]
