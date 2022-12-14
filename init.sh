#!/bin/bash

if ! [ -x "$(command -v docker)" ]; then
  echo -e 'Error: docker compose is not installed.\n Installing docker...'
  apt update && sudo apt -y install ca-certificates curl gnupg lsb-relese
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt update && apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

if [ "$#" -ne 2 ] || [ $1 != "-d" ]; then
  echo "Usage: $1 -d <domain_name>"
  exit 1
fi

if [ -f "./nginx/site_config.conf" ]; then
    mv ./nginx/site_config.conf "./nginx/$2.conf"
    sed -i "s/<-->/$2/g" "./nginx/$2.conf"
    sed -i "s/<-->/$2/g" "docker-compose.yml"
fi

docker compose up -d && echo "---------------------------" && docker exec -it webserver service nginx start && docker exec -it webserver certbot certonly --webroot -w /var/www --register-unsafely-without-email --non-interactive -d $2 --agree-tos && echo "---------------------------" && docker compose down && sed -i 's/#//g' "./nginx/$2.conf" && docker compose up -d && docker exec -it webserver service nginx start 
