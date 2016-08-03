#!/bin/bash
#
# Deploy etf-webapp docker container on a remote machine
#
# Usage: ensure docker-machine is installed on your local machine.
# Create a new docker machine with the docker-machine command and
# ensure the instance is running.
#
# Run this script with "bash deploy_etf.sh <machine name>"
#

if [[ -z $1 ]]; then
    echo "Name of target machine expected"
    exit 1
fi
machine_name=$1

echo "Checking machine status:"
docker-machine status $machine_name || \
  echo "Error checking status of machine $machine_name"

status=$(docker-machine status $machine_name)
if [[ "$status" != "Running" ]]; then
    echo
    docker-machine ls
    echo
    echo "Machine $machine_name is not running!"
    exit 1
fi
target=$(docker-machine url $machine_name)
echo "Starting deployment to machine $machine_name - $target"

mkdir -p ./etfenv

depl_files=( docker-compose.yml etf-config.properties htpasswd.txt nginx.conf )

for i in "${depl_files[@]}"
do
   :
   if [ ! -f ./etfenv/$i ]; then
     echo "$i configuration file not found in etfenv directory, downloading default configuration file"
     curl -L https://raw.githubusercontent.com/interactive-instruments/etf-webapp-docker/master/etfenv/$i > ./etfenv/$i
   fi
done

echo "Starting upload of configuration files..."
docker-machine scp -r ./etfenv "$machine_name":/home/ubuntu/ || \
  ( echo "failed" && exit 1 )
echo "OK"

echo "Starting docker deployment..."
docker-machine ssh "$machine_name" 'sudo bash -s' < ./compose_on_machine.sh
echo "Deployed to $target"
echo "Bye"
