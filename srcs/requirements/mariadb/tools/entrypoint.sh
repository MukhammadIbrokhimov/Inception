#!/bin/bash
set -e

# Colors for debugging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}=== MariaDB Entrypoint Starting ===${NC}"

# Check if the database system database (named 'mysql') exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${YELLOW}MariaDB not initialized. Starting installation...${NC}"

    # 1. Ownership: Ensure mysql user owns the data folder
    chown -R mysql:mysql /var/lib/mysql

    # 2. Initialization: strictly install system tables. 
    echo -e "${GREEN}Installing system tables...${NC}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # 3. Temp Server: Start mysqld in background to run SQL commands
    echo -e "${GREEN}Starting temporary server for configuration...${NC}"
    /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking & 
    PID=$!
    
    echo -e "${GREEN}Temporary server started with PID $PID${NC}"

    # 4. Wait loop: Wait for server to be ready
    echo -e "${GREEN}Waiting for MariaDB to start...${NC}"
    for i in {30..0}; do
        if mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent; then
            break
        fi
        echo "Waiting... $i"
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo -e "${RED}Error: MariaDB failed to start.${NC}"
        exit 1
    fi

    # 5. Configuration: Create users and secure DB
    echo -e "${GREEN}Configuring users and database...${NC}"
    
    # We use 'root' with no password initially (because it's fresh install)
    mysql -u root --socket=/run/mysqld/mysqld.sock <<-EOSQL
        FLUSH PRIVILEGES;

        -- Create the WordPress Database
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

        -- Create the User for WordPress (Host '%' allows access from WP container)
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

        -- Secure the installation
        -- Remove anonymous users
        DELETE FROM mysql.user WHERE User='';
        -- Disallow remote root login (root can only login from localhost)
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        
        -- Set Root Password (Last step to avoid locking ourselves out during this script)
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        
        FLUSH PRIVILEGES;
EOSQL

    echo -e "${GREEN}Configuration complete.${NC}"

    # 6. Shutdown: Stop the temp server so we can restart normally
    # Fixed: Added -p"${DB_ROOT_PASSWORD}" because we just changed the password!
    echo -e "${YELLOW}Stopping temporary server...${NC}"
    if ! mysqladmin -u root -p"${DB_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock shutdown; then
        echo -e "${RED}Shutdown failed. Killing process.${NC}"
        kill -s TERM "$PID"
    fi
    
    # Fixed: Variable case match ($pid -> $PID)
    wait "$PID"
    echo -e "${GREEN}Temporary server stopped.${NC}"

else
    echo -e "${GREEN}MariaDB already initialized. Skipping setup.${NC}"
fi

echo -e "${GREEN}Starting MariaDB Production Server...${NC}"

# Warning: If you use 'exec "$@"', ensure your Dockerfile has CMD ["mysqld", ...]
# If unsure, safe bet is: exec /usr/bin/mysqld --user=mysql --console
exec "$@"