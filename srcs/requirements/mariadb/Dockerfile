FROM alpine:3.20.6

RUN apk add --no-cache mariadb mariadb-client
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY conf /etc/my.cnf.d/mariadb-server.cnf

COPY script.sh .
RUN chmod +x /script.sh

# Expose port (optional if using docker-compose networks)
EXPOSE 3306

ENTRYPOINT ["./script.sh"]