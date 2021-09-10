FROM php:7.4-fpm

#Arguments defined in docker-compose.yml
ARG user
ARG uid

#Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \

#Install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - 
RUN apt-get install -y nodejs npm

#Clear cache
RUN apt-get clean && rm -fr /var/lib/apt/lists/*

#Install php extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets zip

#Get latest composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#Create system user to run Composer and Artisan commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

#Install Redis
RUN pecl install -o -f redis \
    && rm -fr /tmp/pear \
    && docker-php-ext-enable redis

#Set working directory
WORKDIR /var/www

USER $user