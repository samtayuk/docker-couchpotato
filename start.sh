#!/bin/bash
DATA=/config/data
CONFIG=/config/config.ini

function handle_signal {
  PID=$!
  echo "received signal. PID is ${PID}"
  kill -s SIGHUP $PID
}

trap "handle_signal" SIGINT SIGTERM SIGHUP

function set_config(){
    sudo sed -i "s/^\($1\s*=\s*\).*\$/\1$2/" $CONFIG
}

echo checking config.ini
if [ ! -f $CONFIG ]; then
	echo "config.ini doesn't exist. creating default config.ini"
	echo "[core]
url_base = " > $CONFIG
fi

echo setting url base from env
set_config url_base $VIRTUAL_LOCATION


echo "starting couchpotato"
python /opt/couchpotato/CouchPotato.py --config_file=$CONFIG --data_dir=$DATA & wait
echo "stopping couchpotato"
