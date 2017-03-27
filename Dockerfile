FROM alpine:3.4

RUN apk update && apk add mariadb mariadb-client && rm -f /var/cache/apk/*
RUN mysql_install_db --user=mysql
ENV TERM xterm

COPY my.cnf /etc/mysql/
VOLUME /var/lib/mysql
VOLUME /var/log/mysql

ENTRYPOINT ["mysqld_safe"]

EXPOSE 3306
