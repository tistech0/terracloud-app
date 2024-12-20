#!/bin/bash

# Attendre que les variables d'environnement soient appliquées
dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env

# Générer la clé d'application Laravel
php artisan key:generate

# Lancer Apache
exec apache2-foreground
