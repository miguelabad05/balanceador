#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

echo -e "${GREEN}=== Configuración automática de HTTPS con Let's Encrypt ===${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Este script debe ejecutarse como root.${NC}"
    exit 1
fi

if [ -z "$1" ]; then
    echo -e "${RED}Uso: $0 <dominio>"
    echo -e "Ejemplo: $0 balanceador.midominio.com${NC}"
    exit 1
fi

DOMAIN="$1"

echo -e "${YELLOW}Actualizando paquetes...${NC}"
apt update -y

echo -e "${YELLOW}Instalando Certbot...${NC}"
apt install certbot python3-certbot-apache -y

if [ ! -f "/etc/apache2/sites-available/loadbalancer.conf" ]; then
    echo -e "${RED}No se encontró /etc/apache2/sites-available/loadbalancer.conf"
    echo -e "Asegúrate de haber configurado el balanceador antes de ejecutar este script.${NC}"
    exit 1
fi

echo -e "${YELLOW}Actualizando ServerName en loadbalancer.conf...${NC}"
sed -i "s/ServerName .*/ServerName $DOMAIN/" /etc/apache2/sites-available/loadbalancer.conf

systemctl reload apache2

echo -e "${YELLOW}Solicitando certificado SSL para $DOMAIN...${NC}"
certbot --apache -d "$DOMAIN" --non-interactive --agree-tos -m admin@"$DOMAIN"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error al generar el certificado SSL.${NC}"
    exit 1
fi

echo -e "${YELLOW}Habilitando renovación automática...${NC}"
systemctl enable certbot.timer
systemctl start certbot.timer

echo -e "${GREEN}=== Configuración HTTPS completada con éxito ===${NC}"
echo -e "${GREEN}Tu balanceador ahora está disponible en: https://$DOMAIN${NC}"
