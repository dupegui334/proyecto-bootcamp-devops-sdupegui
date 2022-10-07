#!/bin/bash
# Crear un archivo con el la configuración de la base de datos
echo "$DB_USER:$DB_PORT"
echo "DATABASE_URL=mysql+pymysql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE" >> .env
while true; do
    flask db upgrade
    if [[ "$?" == "0" ]]; then
        break
    fi
    echo Deploy command failed, retrying in 5 secs...
    sleep 5
done
exec gunicorn -b :5000 --access-logfile - --error-logfile - microblog:app