#!/bin/bash
# Called from update_etf.sh script on target machine:
# docker-machine ssh machine_name 'sudo bash -s' < ./recompose_on_machine.sh

user=$(whoami)

if [[ $EUID -ne 0 ]]; then
  echo "Expected to be run as root user on the target machine" 2>&1
  exit 1
fi

docker-compose --version || \
  ( echo "Error getting docker-compose version" && exit 1 )

cd /home/ubuntu/etfenv

echo "Reomposing..."
docker-compose stop
docker-compose rm -f
docker-compose pull
docker-compose up -d
echo "OK"

exit 0
