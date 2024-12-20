#!/bin/bash

# Attendre que les variables d'environnement soient appliquées
dockerize -template /var/www/html/.env.tmpl:/var/www/html/.env

# Vérifier si une clé Laravel existe déjà dans le fichier .env
if grep -q "^APP_KEY=" /var/www/html/.env; then
    echo "APP_KEY déjà défini, pas besoin de le régénérer."
else
    # Générer une nouvelle clé d'application Laravel sans confirmation
    APP_KEY=$(php artisan key:generate --show)
    if [ -n "$APP_KEY" ]; then
        echo "APP_KEY=$APP_KEY" >> /var/www/html/.env
        echo "Clé d'application Laravel générée : $APP_KEY"
    else
        echo "Erreur : Impossible de générer APP_KEY !" >&2
        exit 1
    fi
fi

# Vérifier les permissions sur le fichier .env
chown www-data:www-data /var/www/html/.env
chmod 644 /var/www/html/.env

# Lancer Apache
exec apache2-foreground
