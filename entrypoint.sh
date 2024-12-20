#!/bin/bash

# Attendre que les variables d'environnement soient appliquées
dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env

# Générer la clé d'application Laravel sans confirmation
php artisan key:generate --force

# Lancer Apache
exec apache2-foreground
