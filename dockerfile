FROM php:8.2-apache
LABEL maintainer="eberj.blanco@gmail.com"

RUN echo "Configurando PHP..........................................................."

COPY ./php.ini /usr/local/etc/php/php.ini

RUN apt-get update && \
      apt-get -y install sudo

RUN curl https://getcomposer.org/composer.phar -o /usr/bin/composer && chmod +x /usr/bin/composer
RUN composer self-update

#RUN docker-php-ext-install intl
#RUN docker-php-ext-install opcache

RUN apt-get update \
    && apt-get install -y git acl openssl openssh-client wget zip vim libssh-dev \
    && apt-get install -y libpng-dev zlib1g-dev libzip-dev libxml2-dev libicu-dev \
    && docker-php-ext-install intl pdo pdo_mysql zip gd soap bcmath sockets \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache 

RUN apt-get update && apt-get install -y librabbitmq-dev libssh-dev \
    && docker-php-ext-install opcache bcmath sockets \
    && pecl install amqp \
    && docker-php-ext-enable amqp
    
RUN docker-php-ext-install mysqli

#RUN apt-get update \
#    && apt-get install -y git wget zip \
#    && apt-get install -y  intl pdo pdo_mysql zip

RUN a2enmod rewrite

RUN apt install -y curl
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
RUN apt install -y symfony-cli

RUN chmod -R 777 /var/www/

RUN echo 'SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1' >> /etc/apache2/apache2.conf

RUN curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor | sudo tee /usr/share/keyrings/stripe.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | sudo tee -a /etc/apt/sources.list.d/stripe.list
RUN sudo apt update
