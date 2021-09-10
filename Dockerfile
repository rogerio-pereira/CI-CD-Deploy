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
    nodejs \
    npm

#Update node
#RUN npm cache clean
RUN npm install -g n
RUN n stable

#Clear cache
RUN apt-get clean && rm -fr /var/lib/apt/lists/*

#Install php extensions
RUN docker-php-ext-install mbstring ctype fileinfo openssl PDO bcmath json tokenizer xml zip sqlite3

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