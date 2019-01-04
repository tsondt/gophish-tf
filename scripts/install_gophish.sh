#!/bin/bash -xe

VERSION="0.7.1"
FILENAME="gophish-v${VERSION}-linux-64bit.zip"
URL="https://github.com/gophish/gophish/releases/download/${VERSION}/${FILENAME}"
INSTALL_DIR="/opt/gophish"

apt-get update && apt-get install -y curl unzip

mkdir -p "${INSTALL_DIR}"

sudo useradd --no-create-home --shell "/bin/false" "gophish"

pushd ${INSTALL_DIR}

echo "Downloading Gophish from ${URL}"
curl -s -L -O "${URL}" &&
unzip "${FILENAME}" && rm -f "${FILENAME}"

cat>config.json<<EOF
{
    "admin_server" : {
        "listen_url" : "0.0.0.0:4433",
        "use_tls": true,
        "cert_path": "admin.crt",
        "key_path": "admin.key"
    },
    "phish_server": {
        "listen_url" : "0.0.0.0:443",
        "use_tls": false,
        "cert_path": "domain.crt",
        "key_path": "domain.key"
    },
    "db_name": "sqlite3",
	"db_path": "gophish.db",
	"migrations_prefix": "db/db_",
	"contact_address": "",
	"logging": {
		"filename": ""
	}
}
EOF

mv /home/ubuntu/start_gophish.sh ./

popd

sudo chown -R gophish:gophish "${INSTALL_DIR}"

tee /etc/systemd/system/gophish.service <<EOF
[Unit]
Description=gophish
After=network-online.target
Wants=network-online.target

[Service]
User=gophish
Group=gophish
AmbientCapabilities=CAP_NET_BIND_SERVICE
Environment="GOPHISH_BIN_PATH=/opt/gophish/"
Environment="GOPHISH_LOG_PATH=/opt/gophish/"
ExecStart=/bin/bash /opt/gophish/start_gophish.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF