#!/bin/sh
set -e

echo "Starting MariaDB initialization"

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First run detected - initializing database"
    
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    echo "Database structure created, configuring"
    
    mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';

DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "Database initialization complete"
else
    echo "Database already initialized, skipping setup"
fi

echo "Starting MariaDB server"
exec mysqld --user=mysql --console
