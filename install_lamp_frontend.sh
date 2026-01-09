#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

echo -e "${GREEN}=== Instalador LAMP para Frontend ===${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Este script debe ejecutarse como root.${NC}"
    exit 1
fi

echo -e "${YELLOW}Actualizando paquetes...${NC}"
apt update -y && apt upgrade -y

echo -e "${YELLOW}Instalando Apache...${NC}"
apt install apache2 -y

systemctl enable apache2
systemctl start apache2

echo -e "${YELLOW}Instalando cliente MySQL/MariaDB...${NC}"
apt install mariadb-client -y

echo -e "${YELLOW}Instalando PHP y módulos...${NC}"
apt install php php-mysql php-cli php-curl php-xml php-mbstring php-zip php-gd -y

echo -e "${YELLOW}Creando archivo info.php...${NC}"
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

chown www-data:www-data /var/www/html/info.php

echo -e "${YELLOW}Reiniciando Apache...${NC}"
systemctl restart apache2

echo -e "${GREEN}=== Instalación LAMP completada en el frontend ===${NC}"
echo -e "${GREEN}Puedes probar PHP visitando: http://<IP_FRONTEND>/info.php${NC}"
