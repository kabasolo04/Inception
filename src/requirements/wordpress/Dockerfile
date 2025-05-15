FROM debian:oldstable

LABEL maintainer="koldobikaabasolo@gmail.com"

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysqli \
    php7.4-curl \
    php7.4-gd \
    php7.4-xml \
    php7.4-mbstring \
    curl \
    unzip \
    mariadb-client \
    && apt-get clean

WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php7.4-fpm", "-F"]
