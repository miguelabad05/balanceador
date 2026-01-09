#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

echo -e "${GREEN}=== Instalador de Apache Load Balancer ===${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Este script debe ejecutarse como root.${NC}"
    exit 1
fi

echo -e "${YELLOW}Actualizando paquetes...${NC}"
apt update -y && apt upgrade -y

echo -e "${YELLOW}Instalando Apache...${NC}"
apt install apache2 -y

echo -e "${YELLOW}Habilitando módulos de balanceo...${NC}"
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

BALANCER_CONF="/etc/apache2/sites-available/loadbalancer.conf"

echo -e "${YELLOW}Creando configuración del balanceador en:${NC} $BALANCER_CONF"

cat > $BALANCER_CONF <<EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName balanceador.local

    <Proxy "balancer://mycluster">
        BalancerMember http://192.168.1.101
        BalancerMember http://192.168.1.102
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPass "/" "balancer://mycluster/"
    ProxyPassReverse "/" "balancer://mycluster/"

    ErrorLog \${APACHE_LOG_DIR}/balancer_error.log
    CustomLog \${APACHE_LOG_DIR}/balancer_access.log combined
</VirtualHost>
EOF

echo -e "${YELLOW}Activando configuración del balanceador...${NC}"
a2dissite 000-default.conf
a2ensite loadbalancer.conf

echo -e "${YELLOW}Reiniciando Apache...${NC}"
systemctl restart apache2

systemctl enable apache2

echo -e "${GREEN}=== Instalación completada ===${NC}"
echo -e "${GREEN}Apache ahora funciona como balanceador de carga.${NC}"
echo -e "${GREEN}Edita los servidores backend en:${NC} $BALANCER_CONF"
