FROM alpine:3.22

RUN apk add --no-cache openrc php php-phar php-fpm php-mysqli php-mbstring curl

COPY conf/wp.conf /etc/php83/php-fpm.d/www.conf
COPY tools/php.ini /etc/php83/
COPY tools/script.sh .

RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]
