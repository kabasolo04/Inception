FROM alpine:latest

LABEL maintainer="koldobikaabasolo@gmail.com"

RUN apk update && apk add nginx

#COPY docker/nginx/default.conf /etc/nginx/conf.d

CMD ["nginx", "-g", "daemon off;"]