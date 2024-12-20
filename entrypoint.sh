#!/bin/bash

# Attendre que les variables d'environnement soient appliquées
dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env

# Créer les répertoires nécessaires
mkdir -p /var/www/html/bootstrap/cache
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views

# Définir les permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Générer la clé d'application Laravel
APP_KEY=$(php artisan key:generate --show)
echo "APP_KEY=$APP_KEY" >> /var/www/html/.env

# Lancer Apache
exec apache2-foreground
