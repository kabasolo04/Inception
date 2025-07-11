FROM alpine:3.20.6

RUN apk add --no-cache mariadb mariadb-client

# Create necessary directory with correct permissions
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy config
COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy initialization SQL and script
COPY init.sql /etc/mysql/init.sql
COPY script.sh /script.sh
RUN chmod +x /script.sh

# Expose port (optional if using docker-compose networks)
EXPOSE 3306

# Run the entrypoint script
ENTRYPOINT ["./script.sh"]