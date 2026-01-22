FROM alpine:3.22

RUN apk add --no-cache nginx openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && mkdir -p /etc/nginx/ssl

#CMD ["nginx", "-g", "daemon off;"]

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]