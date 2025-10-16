#!/bin/bash
set -e

echo "Starting MariaDB initialization..."

# Read secrets from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Check if this is the first run (database not initialized)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First run detected - initializing database..."
    
    # Initialize the database system tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    echo "Database structure created, configuring..."
    
    # Start MariaDB temporarily in bootstrap mode to run setup SQL
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

-- Remove anonymous users (security)
DELETE FROM mysql.user WHERE User='';

-- Remove remote root login (security)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create WordPress database with utf8mb4
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create WordPress user (can connect from any host)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Grant all privileges on WordPress database to WordPress user
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Apply all changes
FLUSH PRIVILEGES;
EOF

    echo "Database initialization complete!"
else
    echo "Database already initialized, skipping setup..."
fi

# Start MariaDB in foreground
echo "Starting MariaDB server"
exec mysqld --user=mysql --console
