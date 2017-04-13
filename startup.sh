#!/bin/sh

if [ -d /app/mysql ]; then
  echo "[i] MySQL directory already present, skipping creation"
else
  echo "[i] MySQL data directory not found, creating initial DBs"

  mysql_install_db --user=root > /dev/null

  if [ "$DB_ROOT_PASSWORD" = "" ]; then
    DB_ROOT_PASSWORD=111111
    echo "[i] MySQL root Password: $DB_ROOT_PASSWORD"
  fi

  DB_DATABASE=${DB_DATABASE:-""}
  DB_USERNAME=${DB_USERNAME:-""}
  DB_PASSWORD=${DB_PASSWORD:-""}

  if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
  fi

  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
      return 1
  fi

  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$DB_ROOT_PASSWORD" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
EOF

  if [ "$DB_DATABASE" != "" ]; then
    echo "[i] Creating database: $DB_DATABASE"
    echo "CREATE DATABASE IF NOT EXISTS \`$DB_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

    if [ "$DB_USERNAME" != "" ]; then
      echo "[i] Creating user: $DB_USERNAME with password $DB_PASSWORD"
      echo "GRANT ALL ON \`$DB_DATABASE\`.`localhost` to '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';" >> $tfile
      echo "GRANT ALL ON \`$DB_DATABASE\`.* to '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';" >> $tfile
    fi
  fi

  /usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
  rm -f $tfile
fi


exec /usr/bin/mysqld --user=root --console
