#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

echo -e "${GREEN}=== Instalador LAMP para Backend ===${NC}"

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

echo -e "${YELLOW}Instalando servidor MariaDB...${NC}"
apt install mariadb-server -y

systemctl enable mariadb
systemctl start mariadb

echo -e "${YELLOW}Aplicando configuración de seguridad de MariaDB...${NC}"
mysql_secure_installation <<EOF

y
n
y
y
y
EOF

echo -e "${YELLOW}Instalando PHP y módulos necesarios...${NC}"
apt install php php-mysql php-cli php-curl php-xml php-mbstring php-zip php-gd php-json -y

echo -e "${YELLOW}Creando archivo info.php para pruebas...${NC}"
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
chown www-data:www-data /var/www/html/info.php

echo -e "${YELLOW}Reiniciando Apache...${NC}"
systemctl restart apache2

echo -e "${GREEN}=== Instalación LAMP completada en el backend ===${NC}"
echo -e "${GREEN}Puedes probar PHP visitando: http://<IP_BACKEND>/info.php${NC}"
echo -e "${GREEN}Recuerda configurar usuarios y bases de datos en MariaDB según tus necesidades.${NC}"
