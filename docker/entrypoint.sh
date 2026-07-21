#!/bin/bash

# If the vendor folder does not exist, run composer install
if [ ! -d "vendor" ]; then
    echo "Instalando dependências do Composer..."
    composer install --no-interaction
fi

# If the .env file does not exist, create it from .env.example
if [ ! -f .env ]; then
    echo "Criando arquivo .env..."
    cp .env.example .env
fi

# If the APP_KEY is empty or missing, generate a new key
if ! grep -q "^APP_KEY=base64:" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d '=' -f 2)" ]; then
    echo "Gerando chave da aplicação (APP_KEY)..."
    php artisan key:generate --no-interaction
fi
# ---------------------------------

# If the Octane package is not in composer.json, install it
if ! grep -q "laravel/octane" composer.json; then
    echo "Instalando Laravel Octane..."
    composer require laravel/octane --no-interaction
fi

# If the Octane configuration file does not exist, run the installer
if [ ! -f "config/octane.php" ]; then
    echo "Configurando Laravel Octane com Swoole..."
    php artisan octane:install --server=swoole --no-interaction
fi

# Ensure the database folder exists and create the SQLite file if it doesn't exist
if [ ! -f "database/database.sqlite" ]; then
    echo "Criando arquivo SQLite padrão..."
    mkdir -p database
    touch database/database.sqlite
fi

# Roda as migrações de forma segura (o migrate pula o que já foi rodado)
echo "Executando migrações do banco de dados..."
php artisan migrate --force
# ---------------------------------

echo "Iniciando o Laravel Octane..."
# Executes the final Octane command and keeps the container running
exec php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000 --watch