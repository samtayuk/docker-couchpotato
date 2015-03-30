#!/bin/bash
DATA=/config/data
CONFIG=/config/config.ini

function handle_signal {
  PID=$!
  echo "received signal. PID is ${PID}"
  kill -s SIGHUP $PID
}

trap "handle_signal" SIGINT SIGTERM SIGHUP

function set_config() {
    sudo sed -i "s/^\($1\s*=\s*\).*\$/\1$2/" $CONFIG
}

echo checking config.ini
if [ ! -f $CONFIG ]; then
    echo "config.ini doesn't exist. creating default config.ini"
    echo "[core]
url_base = " > $CONFIG
    crudini --set "$CONFIG" "blackhole" "enabled" "0"
    crudini --set "$CONFIG" "sabnzbd" "enabled" "1"
    crudini --set "$CONFIG" "sabnzbd" "category" "films"
    crudini --set "$CONFIG" "renamer" "from" "/data/downloads/complete/films"
    crudini --set "$CONFIG" "renamer" "to" "/data/films"
    crudini --set "$CONFIG" "manage" "library" "/data/films"
    crudini --set "$CONFIG" "sabnzbd" "api_key" ""
    crudini --set "$CONFIG" "sabnzbd" "host" "localhost:8080"
fi

if [ ! -z "$SABNZBD_ENV_API_KEY" ]; then
    echo "SABNZBD API Key: $SABNZBD_ENV_API_KEY"
    crudini --set --existing "$CONFIG" "sabnzbd" "api_key" "$SABNZBD_ENV_API_KEY"
    crudini --set --existing "$CONFIG" "sabnzbd" "host" "sabnzbd:8080"
fi

echo setting url base from env
set_config url_base $VIRTUAL_LOCATION

echo "starting couchpotato"
python /opt/couchpotato/CouchPotato.py --config_file=$CONFIG --data_dir=$DATA & wait
echo "stopping couchpotato"
