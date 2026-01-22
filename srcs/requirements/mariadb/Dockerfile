FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY conf/db.conf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/script.sh .
RUN chmod +x /script.sh

# Expose port (optional if using docker-compose networks)
EXPOSE 3306

ENTRYPOINT ["./script.sh"]