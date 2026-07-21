#!/bin/bash

# Se a pasta vendor não existir, roda o composer install
if [ ! -d "vendor" ]; then
    echo "Instalando dependências do Composer..."
    composer install --no-interaction
fi

# Se o arquivo .env não existir, cria a partir do .env.example
if [ ! -f .env ]; then
    echo "Criando arquivo .env..."
    cp .env.example .env
fi

# Se a APP_KEY estiver vazia ou ausente, gera uma nova chave
if ! grep -q "^APP_KEY=base64:" .env || [ -z "$(grep '^APP_KEY=' .env | cut -d '=' -f 2)" ]; then
    echo "Gerando chave da aplicação (APP_KEY)..."
    php artisan key:generate --no-interaction
fi
# ---------------------------------

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

# Garante que a pasta database existe e cria o arquivo sqlite vazio se não existir
if [ ! -f "database/database.sqlite" ]; then
    echo "Criando arquivo SQLite padrão..."
    mkdir -p database
    touch database/database.sqlite
fi

# Roda as migrações apenas se a tabela 'migrations' ainda não existir no SQLite
if ! php artisan db:show --database=sqlite > /dev/null 2>&1 || [ -z "$(php artisan db:table migrations --database=sqlite 2>/dev/null)" ]; then
    echo "Executando migrações do banco de dados..."
    php artisan migrate --force
fi
# ---------------------------------

echo "Iniciando o Laravel Octane..."
# Executa o comando final do Octane e mantém o container rodando
exec php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000 --watch