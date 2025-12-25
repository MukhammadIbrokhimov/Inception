#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== MariaDB Container Starting ===${NC}"

if [ ! -f /var/lib/mysql/mariadb ]; then
    echo -e "${GREEN}MariaDB is not initialized, starting MariaDB...${NC}"
    exec mysqld --user=mysql --datadir=/var/lib/mysql

    echo -e "${GREEN}MariaDB initialized successfully.${NC}"
else
    echo -e "${GREEN}MariaDB is already initialized.${NC}"
fi

exec "$@"
