FROM alpine:3.20.6

RUN apk add --no-cache nginx

RUN apk add openssl

COPY conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]