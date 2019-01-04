!#/bin/bash

if [[ -z $1 ]]; then
    echo "Usage: install_le_cert.sh <DOMAIN NAME>"
    return 1
fi

apt-get update && apt-get install -y software-properties-common
add-apt-repository ppa:certbot/certbot
apt-get update && apt-get install certbot

certbot certonly --standalone -d "$1"

cp "/etc/letsencrypt/live/$1/fullchain.pem" "/opt/gophish/admin.crt"
cp "/etc/letsencrypt/live/$1/privkey.pem" "/opt/gophish/admin.key"
chown gophish:gophish admin.*
chmod 400 admin.*
