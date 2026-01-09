#!/bin/bash

# Nombre del archivo de configuración
ENV_FILE=".env"

# 1. Verificar si el archivo .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: El archivo $ENV_FILE no se encontró."
    exit 1
fi

# 2. Leer el archivo línea por línea
echo "Cargando variables desde $ENV_FILE..."
while IFS='=' read -r key value; do
    # Ignorar líneas que sean comentarios (#) o estén vacías
    if [[ "$key" =~ ^#.* ]] || [[ -z "$key" ]]; then
        continue
    fi

    # Limpiar espacios en blanco al inicio/final de la clave y el valor
    key=$(echo $key | xargs)
    value=$(echo $value | xargs)

    # Exportar la variable al entorno
    export "$key=$value"
    echo "   -> Exportada: $key"

done < "$ENV_FILE"

echo "✅ Variables cargadas."
echo "---"

# 3. Utilizar las variables cargadas
echo "Utilizando variables en el script..."
echo "Puerto: $PORT"
echo "Base de Datos: $DB_HOST"
