# syntax=docker/dockerfile:1

# ================================
# Stage 1: Install Composer deps
# ================================
FROM composer:lts AS deps
WORKDIR /app

RUN --mount=type=bind,source=composer.json,target=composer.json \
    --mount=type=bind,source=composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-interaction --prefer-dist


# ================================
# Stage 2: Final PHP-Apache image
# ================================
FROM php:8.2-apache AS final

# Install necessary PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Use production PHP config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy vendor dari stage deps
COPY --from=deps /app/vendor /var/www/html/vendor

# Copy source code
COPY ./src /var/www/html

# Use non-root user for security
USER www-data

