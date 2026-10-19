
#!/bin/bash

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql
export MYSQL_ROOT_PASSWORD="$(cat /run/secrets/MYSQL_ROOT_PASSWORD)"
export MYSQL_PASSWORD="$(cat /run/secrets/MYSQL_PASSWORD)"

echo "Comprobando inicialización de MariaD"

if [ ! -f /var/lib/mysql/.initialized ]; then


    echo "Inicializando MariaDB..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql; 

    mysqld_safe &
    
    until mysqladmin ping --silent; do
        echo "Esperando MariaDB..."
        sleep 2
    done
    echo "hola"
    mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

    mysql -e "FLUSH PRIVILEGES;"


    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    touch /var/lib/mysql/.initialized

fi

exec mysqld_safe