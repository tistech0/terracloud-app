#!/bin/bash

# Attendre que les variables d'environnement soient appliquées
dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env

# Générer la clé d'application Laravel sans confirmation
APP_KEY=$(php artisan key:generate --show)
echo "APP_KEY=$APP_KEY" >> /var/www/html/.env

# Lancer Apache
exec apache2-foreground
