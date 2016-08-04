#!/bin/bash
#
# Update etf-webapp docker container on a remote machine
#
# Usage: ensure etf-webapp has been deployed with deploy_etf.sh.
#
# Run this script with "bash update_etf.sh <machine name>"
#

if [[ -z $1 ]]; then
    echo "Name of target machine expected"
    exit 1
fi
machine_name=$1

echo "Checking machine status:"
docker-machine status $machine_name || \
  ( echo "Error checking status of machine $machine_name" && exit 1 )

status=$(docker-machine status $machine_name)
if [[ "$status" != "Running" ]]; then
    echo
    docker-machine ls
    echo
    echo "Machine $machine_name is not running!"
    exit 1
fi
target=$(docker-machine url $machine_name)

echo "Starting update of machine $machine_name - $target"

docker-machine ssh "$machine_name" 'sudo bash -s' < ./recompose_on_machine.sh
echo "$target updated"
echo "Bye"
