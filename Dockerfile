# Dockerfile for QloApps deployment
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo_mysql \
    mysqli \
    zip \
    xml \
    mbstring \
    curl \
    soap \
    simplexml \
    dom

# Enable Apache modules
RUN a2enmod rewrite headers expires deflate

# Copy application files
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/cache \
    && chmod -R 777 /var/www/html/log \
    && chmod -R 777 /var/www/html/img \
    && chmod -R 777 /var/www/html/config \
    && chmod -R 777 /var/www/html/modules \
    && chmod -R 777 /var/www/html/upload \
    && chmod -R 777 /var/www/html/download

# Configure PHP
RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/memory.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/memory.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/memory.ini \
    && echo "max_execution_time = 500" >> /usr/local/etc/php/conf.d/memory.ini

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

