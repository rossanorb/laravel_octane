FROM php:8.3-cli-alpine

# Instalar dependências do sistema, utilitário PHP e NODEJS com NPM
RUN apk add --no-cache \
    bash \
    curl \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    supervisor \
    nodejs \
    npm

# Instalar o chokidar globalmente
RUN npm install -g chokidar

# CONFIGURAÇÃO CRUCIAL: Diz ao Node onde encontrar o chokidar global
ENV NODE_PATH=/usr/local/lib/node_modules

# Instalar extensões PHP necessárias e o Swoole
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql zip pcntl gd swoole opcache

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www

EXPOSE 8000

# --- NOVIDADE AQUI ---
# Copia o script de inicialização para dentro do container
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Dá permissão de execução ao script e corrige quebras de linha do Windows (CRLF) se necessário
RUN chmod +x /usr/local/bin/entrypoint.sh && sed -i 's/\r$//' /usr/local/bin/entrypoint.sh

# Define o script como o comando de inicialização
ENTRYPOINT ["entrypoint.sh"]

# CMD ["php", "artisan", "octane:start", "--server=swoole", "--host=0.0.0.0", "--port=8000", "--watch"]
