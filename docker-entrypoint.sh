#!/bin/bash

echo "Waiting for database to be ready..."
max_tries=30
counter=1

while ! php artisan db > /dev/null 2>&1; do
    if [ $counter -gt $max_tries ]; then
        echo "Unable to connect to the database after $max_tries attempts. Exiting..."
        exit 1
    fi
    echo "Waiting for database connection... (Attempt $counter/$max_tries)"
    sleep 5
    counter=$((counter + 1))
done

echo "Database connection successful!"

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