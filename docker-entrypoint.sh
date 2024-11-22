#!/bin/bash

# Exécuter les migrations
echo "Running database migrations..."
php artisan migrate --force

# Exécuter les seeds
echo "Running database seeds..."
php artisan db:seed --force

# Optimiser l'application
php artisan optimize
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Définir les permissions
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache

# Démarrer Apache
echo "Starting Apache..."
apache2-foreground