FROM alpine:latest

RUN apk update && apk add nginx

COPY docker/nginx/default.conf /etc/nginx/conf.d

CMD ["nginx", "-g", "daemon off;"]