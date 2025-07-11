FROM alpine:3.20.6

RUN apk add --no-cache openrc php php-phar php-fpm php-mysqli php-mbstring curl

COPY www.conf /etc/php83/php-fpm.d/
COPY php.ini /etc/php83/

RUN apk add --no-cache mariadb-client

COPY script.sh .
RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]
