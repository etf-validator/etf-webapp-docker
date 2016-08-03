#!/bin/bash
# Called from deploy.sh script on target machine:
# docker-machine ssh machine_name 'sudo bash -s' < ./compose_on_machine.sh

user=$(whoami)

if [[ $EUID -ne 0 ]]; then
  echo "Expected to be run as root user on the target machine" 2>&1
  exit 1
fi

echo "Downloading docker-compose"
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

docker-compose --version

cd /home/ubuntu/etfenv

echo "Composing..."
docker-compose up -d
echo "OK"

echo "2  8    * * *   root    rm -R /etf/testdata/temporary-*" >> /etc/crontab
echo "3  8    * * *   root    rm -R /etf/ds/db/data/etf-tdb-*" >> /etc/crontab

chmod 777 -R /etf

echo
docker-compose ps
echo

exit 0
