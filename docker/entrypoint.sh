#!/bin/bash

# Se a pasta vendor não existir, roda o composer install
if [ ! -d "vendor" ]; then
    echo "Instalando dependências do Composer..."
    composer install --no-interaction
fi

# Se o pacote do Octane não estiver no composer.json, instala ele
if ! grep -q "laravel/octane" composer.json; then
    echo "Instalando Laravel Octane..."
    composer require laravel/octane --no-interaction
fi

# Se o arquivo de configuração do Octane não existir, roda o instalador
if [ ! -f "config/octane.php" ]; then
    echo "Configurando Laravel Octane com Swoole..."
    php artisan octane:install --server=swoole --no-interaction
fi

echo "Iniciando o Laravel Octane..."
# Executa o comando final do Octane e mantém o container rodando
exec php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000 --watch
