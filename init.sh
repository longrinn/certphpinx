#!/bin/bash

if ! [ -x "$(command -v compose)" ]; then
  echo 'Error: docker compose is not installed.' >&2
  exit 1
fi

if [ "$#" -ne 2 ] || [ $1 != "-d" ]; then
  echo "Usage: $1 -d <domain_name>"
  exit 1
fi

if [ -f "./nginx/default.conf" ]; then
    mv ./nginx/default.conf "./nginx/$2.conf"
    sed -i "s/<-->/$2/g" "./nginx/$2.conf"
    sed -i "s/<-->/$2/g" "docker-compose.yml"
fi

docker compose up -d && echo "---------------------------" && docker exec -it webserver service nginx start && docker exec -it webserver certbot certonly --webroot -w /var/www --register-unsafely-without-email --non-interactive -d $2 --agree-tos && echo "---------------------------" && docker compose down && sed -i 's/#//g' "./nginx/$2.conf" && docker compose up -d && docker exec -it webserver service nginx start 
