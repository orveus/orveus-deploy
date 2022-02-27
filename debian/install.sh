#! /usr/bin/env bash
echo "updating repository info"

sudo apt update

echo "installing docker dependencies"

sudo apt -y install ca-certificates curl gnupg lsb-release

echo "loading docker repository keys"

curl --retry 3 -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "installing docker repository keys and installing docker repository"

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "updating repository info"

sudo apt update

echo "installing docker"

sudo apt -y install docker-ce docker-ce-cli containerd.io

echo "downloading docker-compose"

sudo curl -L --retry 3 "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "setting execution right to docker compose"

sudo chmod +x /usr/local/bin/docker-compose

echo "link docker compose to usr bin"

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || echo "docker compose is already linked"

echo "creating ssl dir"

mkdir ssl || "ssl directory exists already"

echo "downloading dummy certificate.crt"

curl --retry 3 https://raw.githubusercontent.com/domschmidt/orveus-deploy/main/ssl/ssl_certificate.crt > ssl/ssl_certificate.crt

echo "downloading dummy certificate.key"

curl --retry 3 https://raw.githubusercontent.com/domschmidt/orveus-deploy/main/ssl/ssl_certificate.key > ssl/ssl_certificate.key

echo "downloading backup script"

curl --retry 3 https://raw.githubusercontent.com/domschmidt/orveus-deploy/main/debian/backup.sh > backup.sh

sudo chmod +x backup.sh

echo "downloading restore script"

curl --retry 3 https://raw.githubusercontent.com/domschmidt/orveus-deploy/main/debian/restore.sh > restore.sh

sudo chmod +x restore.sh

echo "downloading docker-compose.yml"

curl --retry 3 https://raw.githubusercontent.com/domschmidt/orveus-deploy/main/debian/docker-compose.yml > docker-compose.yml

echo "requesting docker login"

sudo docker login

mkdir database || echo "database directory exists already"

echo "prepare orveus-db permissions"

sudo docker-compose up --no-start

sudo docker start orveus-db

echo "applying rights"

sudo chown -R $(sudo docker exec orveus-db id -u) database

sudo docker-compose stop

echo "docker-compose up"

sudo docker-compose up -d

echo "done"
