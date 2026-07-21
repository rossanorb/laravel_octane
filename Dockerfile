FROM php:8.3-cli-alpine

# Install system dependencies, PHP utility, and Node.js with npm
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

# Install chokidar globally
RUN npm install -g chokidar

# CRUCIAL CONFIGURATION: Tells Node where to find the global chokidar
ENV NODE_PATH=/usr/local/lib/node_modules

# Install required PHP extensions and Swoole
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql zip pcntl gd swoole opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www

EXPOSE 8000

# Copies the startup script into the container
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Grants execution permission to the script and fixes Windows line endings (CRLF) if necessary
RUN chmod +x /usr/local/bin/entrypoint.sh && sed -i 's/\r$//' /usr/local/bin/entrypoint.sh

# define the script with the initialization command
ENTRYPOINT ["entrypoint.sh"]
