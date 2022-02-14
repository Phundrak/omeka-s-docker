FROM php:7.4-apache

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    curl \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

# install the PHP extensions we need
RUN pecl install mcrypt-1.0.4 
RUN docker-php-ext-enable mcrypt
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/

# workdir already exist - no need to use mkdir
ARG working_dir=/var/www/html 

RUN curl -J -L -s -k \
    'https://github.com/omeka/omeka-s/releases/download/v3.1.1/omeka-s-3.1.1.zip' \
    -o /var/www/omeka-s.zip \
&&  unzip -q /var/www/omeka-s.zip -d /var/www/ \
&&  rm /var/www/omeka-s.zip \
&&  rm -rf ${working_dir} \
&&  mv /var/www/omeka-s ${working_dir} \
&&  chown -R www-data:www-data ${working_dir}

COPY --chown=www-data:www-data ./database.ini /var/www/html/config/database.ini
COPY --chown=www-data:www-data ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY --chown=www-data:www-data ./.htaccess /var/www/html/.htaccess

RUN chown -R www-data:www-data $working_dir
USER www-data

CMD ["apache2-foreground"]
